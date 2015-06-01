package net.sqf.escali.control;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;

import javax.xml.stream.Location;
import javax.xml.stream.XMLStreamException;
import javax.xml.xpath.XPathExpressionException;

import net.sqf.escali.control.report.ModelNodeFac;
import net.sqf.escali.control.report.SVRLMessage;
import net.sqf.escali.control.report._Report;
import net.sqf.escali.control.report._SVRLMessage;
import net.sqf.escali.resources.EscaliRsourcesInterface;
import net.sqf.stringUtils.TextSource;
import net.sqf.utils.process.log.DefaultProcessLoger;
import net.sqf.xmlUtils.exceptions.XSLTErrorListener;
import net.sqf.xmlUtils.staxParser.NodeInfo;
import net.sqf.xmlUtils.staxParser.StringNode;
import net.sqf.xmlUtils.xpath.XPathReader;
import net.sqf.xmlUtils.xslt.Parameter;
import net.sqf.xmlUtils.xslt.XSLTPipe;

import org.w3c.dom.DOMException;
import org.xml.sax.SAXException;

public class SVRLReport {
	public static String HTML_FORMAT = "html";
	public static String ESCALI_FORMAT = "escali";
	public static String TEXT_FORMAT = "text";
	public static String OXYGEN_FORMAT = "oxygen";
	
	public static XPathReader XPR = new XPathReader();

	private XSLTPipe htmlPrinter = new XSLTPipe("Escali HTML output");
	private XSLTPipe textPrinter = new XSLTPipe("Escali text output");
	private XSLTPipe escaliPrinter = new XSLTPipe("Escali SVRL output");
	
	private final StringNode svrl;
	
	
	private File sourceFile;
	
	private _Report report;

	
	public SVRLReport(TextSource svrl, TextSource input, TextSource schema, EscaliRsourcesInterface resource) throws XSLTErrorListener, IOException, SAXException, XMLStreamException, XPathExpressionException, DOMException, URISyntaxException{
		
		htmlPrinter.addStep(resource.getSvrlPrinter("html"));
		textPrinter.addStep(resource.getSvrlPrinter("text"));
		escaliPrinter.addStep(resource.getSvrlPrinter("escali"));
		
		StringNode source = new StringNode(input);
		
		this.sourceFile = input.getFile();
		this.svrl = new StringNode(svrl);
		
		ArrayList<Parameter> params = new ArrayList<Parameter>();
		params.add(new Parameter("schema", schema.getFile().toURI()));
		params.add(new Parameter("instance", input.getFile().toURI()));
		StringNode escaliReport = new StringNode(escaliPrinter.pipe(svrl, params));
		
		this.report = ModelNodeFac.nodeFac.getReport(XPR.getNode("/es:escali-reports", escaliReport.getDocument()), source);
	}
	
	
	private TextSource getReportAsHTML(){
		return htmlPrinter.pipe(this.svrl.getTextSource(), new DefaultProcessLoger());
	}
	
	private TextSource getReportAsText(){
		return textPrinter.pipe(this.svrl.getTextSource(), new DefaultProcessLoger());
	}
	
	private TextSource getReportEscali(){
		return escaliPrinter.pipe(this.svrl.getTextSource(), new DefaultProcessLoger());
	}
	
	private TextSource getReportOxygen() throws IOException, SAXException, XMLStreamException, XPathExpressionException{
		TextSource oxygenReport = TextSource.createVirtualTextSource(this.svrl.getFile());
		ArrayList<_SVRLMessage> messages = this.report.getMessages();
		for (_SVRLMessage message : messages) {
			String report = oxygenReport.toString() + getOxygenReportEntry(message) + "\n\n";
			oxygenReport.setData(report);
		}
		return oxygenReport;
	}
	
	private String getOxygenReportEntry(_SVRLMessage message) throws XPathExpressionException{
		NodeInfo ni = message.getLocationInIstance();
		Location location = ni.getMarkStartLocation();
	
		String entry = "";
		String level = SVRLMessage.levelToString(message.getErrorLevelInt());
		entry += "Type: " + level.substring(0, 1).toUpperCase() +  "\n";
		entry += "SystemID: " + sourceFile.getAbsolutePath() +  "\n";
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
	
	
//	public TextSource getInput(){
//		return this.source.getTextSource();
//	}
	public File getSourceFile(){
		return this.sourceFile;
	}
	
	public _Report getReport(){
		return this.report;
	}
}
