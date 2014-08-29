package net.sqf.escali.control;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;

import javax.xml.stream.XMLStreamException;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.xpath.XPathExpressionException;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import com.ctc.wstx.io.WstxInputLocation;
import com.sun.org.apache.xpath.internal.NodeSet;

import net.sqf.escali.control.report.ModelNodeFac;
import net.sqf.escali.control.report.Report;
import net.sqf.escali.control.report.SVRLMessage;
import net.sqf.escali.control.report._Report;
import net.sqf.escali.control.report._SVRLMessage;
import net.sqf.escali.resources.EscaliFileResources;
import net.sqf.escali.resources.EscaliRsourcesInterface;
import net.sqf.stringUtils.TextSource;
import net.sqf.xmlUtils.staxParser.PositionalXMLReader;
import net.sqf.xmlUtils.staxParser.StringNode;
import net.sqf.xmlUtils.xpath.XPathReader;
import net.sqf.xmlUtils.xslt.Parameter;
import net.sqf.xmlUtils.xslt.XSLTPipe;

public class SVRLReport {
	public static String HTML_FORMAT = "html";
	public static String ESCALI_FORMAT = "escali";
	public static String TEXT_FORMAT = "text";
	public static String OXYGEN_FORMAT = "oxygen";
	
	public static XPathReader XPR = new XPathReader();

	private XSLTPipe htmlPrinter = new XSLTPipe();
	private XSLTPipe textPrinter = new XSLTPipe();
	
	private final StringNode svrl;
	
	private NodeList messages;
	private NodeList quickFixes;
	
	private StringNode input;
	private TextSource schema;
	
	private _Report report;

	private StringNode escaliReport;
	
	public SVRLReport(TextSource svrl, TextSource input, TextSource schema, EscaliRsourcesInterface resource) throws TransformerConfigurationException, IOException, SAXException, XMLStreamException, XPathExpressionException, DOMException, URISyntaxException{
		XSLTPipe escaliReporter = new XSLTPipe();
		
		htmlPrinter.addStep(resource.getSvrlPrinter("html"));
		textPrinter.addStep(resource.getSvrlPrinter("text"));
		escaliReporter.addStep(resource.getSvrlPrinter("escali"));
		
		this.input = new StringNode(input);
		this.schema = schema;
		
		this.svrl = new StringNode(svrl);
		
		ArrayList<Parameter> params = new ArrayList<Parameter>();
		params.add(new Parameter("schema", schema.getFile().toURI()));
		params.add(new Parameter("instance", input.getFile().toURI()));
		this.escaliReport = new StringNode(escaliReporter.pipe(svrl, params));
		
		this.report = ModelNodeFac.nodeFac.getReport(XPR.getNode("/es:escali-reports", escaliReport.getDocument()), this.input);
	}
	
	
	private TextSource getReportAsHTML(){
		return htmlPrinter.pipe(this.svrl.getTextSource());
	}
	
	private TextSource getReportAsText(){
		return textPrinter.pipe(this.svrl.getTextSource());
	}
	
	private TextSource getReportEscali(){
		return this.escaliReport.getTextSource();
	}
	
	private TextSource getReportOxygen() throws IOException, SAXException, XMLStreamException, XPathExpressionException{
		TextSource oxygenReport = TextSource.createVirtualTextSource(this.escaliReport.getFile());
		ArrayList<_SVRLMessage> messages = this.report.getMessages();
		for (_SVRLMessage message : messages) {
			String report = oxygenReport.toString() + getOxygenReportEntry(message, this.input) + "\n\n";
			oxygenReport.setData(report);
		}
		return oxygenReport;
	}
	
	private String getOxygenReportEntry(_SVRLMessage message, StringNode instanceSN) throws XPathExpressionException{
		Node node = instanceSN.getNode(message.getLocation());
		String userdatakey = node.getNodeType() == Node.ELEMENT_NODE ? PositionalXMLReader.NODE_INNER_LOCATION_START : PositionalXMLReader.NODE_LOCATION_END;
	
		WstxInputLocation location = (WstxInputLocation) node.getUserData(userdatakey);
//		WstxInputLocation locationEnd = (WstxInputLocation) instanceSN.getNode(message.getLocation()).getUserData(PositionalXMLReader.NODE_LOCATION_END);
		String entry = "";
		String level = SVRLMessage.levelToString(message.getErrorLevelInt());
		entry += "Type: " + level.substring(0, 1).toUpperCase() +  "\n";
		entry += "SystemID: " + instanceSN.getAbsPath() +  "\n";
		entry += "Line: " + location.getLineNumber() +  "\n";
		entry += "Column: " + (location.getColumnNumber() - 1) +   "\n";
		if(message.hasLink()){
			entry += "AdditionalInfoURL: " + message.getLink();
		}
		entry += "Description: " + message.getName();
		return entry;
	}
	
	public TextSource getSVRL(){
		return this.svrl.getTextSource();
	}
	
	public TextSource getFormatetReport(String type){
		if(type.equals(HTML_FORMAT)){
			return getReportAsHTML();
		} else if(type.equals(TEXT_FORMAT)){
			return getReportAsText();
		} else if(type.equals(ESCALI_FORMAT)){
			return getReportEscali();
		} else if(type.equals(OXYGEN_FORMAT)) {
			try {
				return getReportOxygen();
			} catch (XPathExpressionException | IOException | SAXException
					| XMLStreamException e) {
				return getSVRL();
			}
		} else{
			return getSVRL();
		}
	}
	
	public NodeList getMessages(){
		return this.messages;
	}
	public NodeList getFixes(){
		return this.quickFixes;
	}
	
	public TextSource getSchema(){
		return this.schema;
	}
	public TextSource getInput(){
		return this.input.getTextSource();
	}
	
	public _Report getReport(){
		return this.report;
	}
}
