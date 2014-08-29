package net.sqf.escali.control;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import javax.xml.stream.XMLStreamException;
import javax.xml.xpath.XPathExpressionException;

import net.sqf.escali.resources.EscaliArchiveResources;
import net.sqf.escali.resources.EscaliFileResources;
import net.sqf.escali.resources.EscaliRsourcesInterface;
import net.sqf.stringUtils.TextSource;
import net.sqf.xmlUtils.staxParser.StringNode;
import net.sqf.xmlUtils.xpath.ProcessNamespaces;
import net.sqf.xmlUtils.xpath.XPathReader;
import net.sqf.xmlUtils.xslt.Parameter;

import org.w3c.dom.Node;
import org.xml.sax.SAXException;

public class Config {
	
	private static XPathReader xpr = new XPathReader();
	
	private StringNode doc;
	
	private File tempFolder;
	private String[] language = null;
	private String[] phase = null;
	private boolean xmlSaveMode = true;
	
	private String changePrefix = "sqfc";
	private boolean supressSQF = false;
	
	
	protected Config(){
	}
	
	protected Config(TextSource conf) throws IOException, SAXException, XMLStreamException, XPathExpressionException{
		this.doc = new StringNode(conf);
		
		this.tempFolder = new File(this.doc.getFile(), "../" + xpr.getString("/es:config/es:tempFolder", doc.getDocument()));
		
		String phase = xpr.getString("/es:config/es:phase", doc.getDocument());
		this.phase = phase.equals("") || phase.equals("#DEFAULT") ? null : phase.split("\\s");
		
		this.xmlSaveMode = xpr.getBoolean("/es:config/es:output/es:xml-save-mode = 'true'", doc.getDocument());
	}
	

	public File getTempFolder(){
		return this.tempFolder;
	}
	
	public boolean hasPhase(){
		return this.phase != null;
	}
	public boolean hasLanguage(){
		return this.language != null;
	}
	
	public String[] getPhase(){
		return this.phase;
	}
	public String[] getLanguage(){
		return this.language;
	}
	public boolean isXmlSaveMode(){
		return this.xmlSaveMode;
	}
	
	public void setPhase(String phase){
		this.phase = new String[]{phase};
	}
	public void setPhase(String[] phases){
		this.phase = phases;
	}

	public void setLanguage(String language){
		this.language = new String[]{language};
	}
	
	public void setLanguage(String[] language){
		this.language = language;
	}
	
	public void setXmlSaveMode(Boolean xmlSaveMode){
		this.xmlSaveMode = xmlSaveMode;
	}
	
	public void setTempFolder(File tempFolder){
		this.tempFolder = tempFolder;
	}

	public String getChangePrefix() {
		return this.changePrefix;
	}
	
	public ArrayList<Parameter> createCompilerParams(){
		ArrayList<Parameter> compileParams = new ArrayList<Parameter>();
		if(hasLanguage()){
			compileParams.add(new Parameter("lang", ProcessNamespaces.ES_NS, 0, getLanguage()));
			}
		if(hasPhase()){
			compileParams.add(new Parameter("phase", 2, getPhase()));
		}
		
		compileParams.add(new Parameter("changePrefix", ProcessNamespaces.SQF_NS, 2, getChangePrefix()));
		if(this.supressSQF){
			compileParams.add(new Parameter("useSQF", ProcessNamespaces.SQF_NS, 2, false));
		}
		
		
		return compileParams;
	}

	public ArrayList<Parameter> createManipulatorParams() {
		ArrayList<Parameter> manipulatorParams = new ArrayList<Parameter>();
		manipulatorParams.add(new Parameter("xml-save-mode", ProcessNamespaces.XSM_NS, this.xmlSaveMode));
		return manipulatorParams;
	}
}
