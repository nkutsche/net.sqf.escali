package net.sqf.escali.control;

import java.io.IOException;

import javax.xml.stream.XMLStreamException;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.xpath.XPathExpressionException;

import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import net.sqf.escali.resources.EscaliFileResources;
import net.sqf.escali.resources.EscaliRsourcesInterface;
import net.sqf.stringUtils.TextSource;
import net.sqf.xmlUtils.staxParser.StringNode;
import net.sqf.xmlUtils.xpath.XPathReader;
import net.sqf.xmlUtils.xslt.XSLTPipe;

public class SchemaInfo {
	private XSLTPipe infoGenerator = new XSLTPipe();
	private static XPathReader xpr = new XPathReader();
	
	
	private String[] phases;
	private String defaultPhase;
	private String[] languages;
	private String defaultLang;
	private final TextSource schema;
	
	protected SchemaInfo(TextSource source, EscaliRsourcesInterface resource) throws TransformerConfigurationException, IOException, SAXException, XMLStreamException, XPathExpressionException{
		this.schema = source;
		infoGenerator.addStep(resource.getSchemaInfo());
		StringNode schemaInfoDoc = new StringNode(infoGenerator.pipe(source));
		
		NodeList phaseNodes = xpr.getNodeSet("/es:schemaInfo/es:phases/es:phase", schemaInfoDoc.getDocument());
		phases = new String[phaseNodes.getLength()];
		for (int i = 0; i < phases.length; i++) {
			phases[i] = xpr.getString("@id", phaseNodes.item(i));
		}
		this.defaultPhase = xpr.getString("/es:schemaInfo/es:phases/@default", schemaInfoDoc.getDocument());
		
		NodeList langNodes = xpr.getNodeSet("/es:schemaInfo/es:languages/es:lang", schemaInfoDoc.getDocument());
		languages = new String[langNodes.getLength()];
		for (int i = 0; i < languages.length; i++) {
			languages[i] = xpr.getString("@code", langNodes.item(i));
		}
		
		this.defaultLang = xpr.getString("/es:schemaInfo/es:languages/@default", schemaInfoDoc.getDocument());
	}
	
	public TextSource getSchema() {
		return schema;
	}

	public String[] getPhases(){
		return this.phases;
	}
	public String getDefaultPhase(){
		return this.defaultPhase;
	}
	public String[] getLanguages(){
		return this.languages;
	}
	public String getDefaultLanguage(){
		return this.defaultLang;
	}
}
