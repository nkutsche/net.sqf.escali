package net.sqf.escali.control;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;

import javax.xml.stream.XMLStreamException;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.xpath.XPathExpressionException;

import net.sqf.escali.control.report._QuickFix;
import net.sqf.escali.resources.EscaliArchiveResources;
import net.sqf.escali.resources.EscaliFileResources;
import net.sqf.escali.resources.EscaliRsourcesInterface;
import net.sqf.stringUtils.TextSource;
import net.sqf.xmlUtils.xslt.Parameter;
import net.sqf.xmlUtils.xslt.XSLTPipe;

import org.xml.sax.SAXException;

public class Escali {
	private final Validator val;
	private final Executor exec;
	private Config config;
	private final EscaliRsourcesInterface resource;
	
	private XSLTPipe htmlPrinter = new XSLTPipe();
	private XSLTPipe textPrinter = new XSLTPipe();
	private SVRLReport report;
	
	public Escali() throws TransformerConfigurationException, FileNotFoundException{
		this(new EscaliArchiveResources());
	}
	
	public Escali(EscaliRsourcesInterface resource) throws TransformerConfigurationException, FileNotFoundException{
		this(ConfigFactory.createConfig(resource.getConfig()), resource);
		
		
	}
	
	public Escali(Config config, EscaliRsourcesInterface resource) throws TransformerConfigurationException, FileNotFoundException {
		this.config = config;
		this.resource = resource;

		this.val = new Validator(this.resource);
		this.exec = new Executor(this.resource);

		htmlPrinter.addStep(this.resource.getSvrlPrinter("html"));
		textPrinter.addStep(this.resource.getSvrlPrinter("text"));
	}

//	public Escali(TextSource config) throws XPathExpressionException, IOException, SAXException, XMLStreamException, TransformerConfigurationException{
//		this(new Config(config));
//	}
	
//	public Escali(File config) throws XPathExpressionException, IOException, SAXException, XMLStreamException, TransformerConfigurationException {
//		this(TextSource.readTextFile(config));
//	}
//	

	public SchemaInfo getSchemaInfo(TextSource schema) throws TransformerConfigurationException, XPathExpressionException, IOException, SAXException, XMLStreamException{
		return new SchemaInfo(schema, this.resource);
	}
	public void compileSchema(TextSource schema, Config config) throws TransformerConfigurationException, FileNotFoundException{
		this.config = config;
		this.compileSchema(schema);
	}
	
	public void compileSchema(TextSource schema) throws TransformerConfigurationException, FileNotFoundException{
		this.val.compileSchema(schema, this.config);
	}
	
	public SVRLReport validate(TextSource input, ArrayList<Parameter> params) throws TransformerException, XPathExpressionException, IOException, SAXException, URISyntaxException, XMLStreamException{
		val.validateInstance(input, params);
		this.report = new SVRLReport(val.getSvrl(), input, this.val.getSchema(), this.resource);
		return this.report;
	}
	
	public SVRLReport validate(TextSource input) throws TransformerException, XPathExpressionException, IOException, SAXException, URISyntaxException, XMLStreamException{
		return validate(input, new ArrayList<Parameter>());
	}
	
	public TextSource validateHTML() throws TransformerConfigurationException{
		return this.report.getFormatetReport(SVRLReport.HTML_FORMAT);
	}
	
	public TextSource validateText() throws TransformerConfigurationException{
		return this.report.getFormatetReport(SVRLReport.TEXT_FORMAT);
	}
	
	public TextSource executeFix(_QuickFix[] fixIds) throws TransformerConfigurationException{
		return this.exec.execute(fixIds, this.report, this.report.getInput(), this.config);
	}
}
