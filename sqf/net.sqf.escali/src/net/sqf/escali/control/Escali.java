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
import net.sqf.utils.process.exceptions.CancelException;
import net.sqf.utils.process.log.ProcessLoger;
import net.sqf.xmlUtils.exceptions.ValidationSummaryException;
import net.sqf.xmlUtils.xslt.Parameter;
import net.sqf.xmlUtils.xslt.XSLTPipe;

import org.xml.sax.SAXException;
import org.xml.sax.SAXNotRecognizedException;
import org.xml.sax.SAXNotSupportedException;

public class Escali {
	private final Validator val;
	private final Executor exec;
	private Config config;
	private final EscaliRsourcesInterface resource;
	
	private XSLTPipe htmlPrinter = new XSLTPipe("Escali HTML output");
	private XSLTPipe textPrinter = new XSLTPipe("Escali Text output");
	private SVRLReport report;
	
	private SchematronBaseValidator baseVal = null;
	
	public Escali() throws TransformerConfigurationException, FileNotFoundException{
		this(new EscaliArchiveResources());
	}
	
	public Escali(EscaliRsourcesInterface resource) throws TransformerConfigurationException, FileNotFoundException{
		this(ConfigFactory.createConfig(resource.getConfig()), resource);
		
		
	}
	
	public Escali(Config config, EscaliRsourcesInterface resource) throws TransformerConfigurationException, FileNotFoundException {
		this(config, resource, true);
	}
	
	protected Escali(Config config, EscaliRsourcesInterface resource, boolean needsBaseValidation) throws TransformerConfigurationException, FileNotFoundException {
		this.config = config;
		this.resource = resource;

		this.val = new Validator(this.resource);
		this.exec = new Executor(this.resource);
		if(needsBaseValidation){
			try {
				this.baseVal = new SchematronBaseValidator(this.resource, this.config);
			} catch (SAXNotRecognizedException e) {
				e.printStackTrace();
			} catch (SAXNotSupportedException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			} catch (CancelException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

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
	public void compileSchema(TextSource schema, Config config, ProcessLoger loger) throws TransformerConfigurationException, FileNotFoundException, CancelException{
		this.config = config;
		
		if(this.baseVal != null){
			try {
				TextSource precompiled = this.val.preCompileSchema(schema, config, loger);
				baseVal.validate(precompiled);
			} catch (ValidationSummaryException e) {
				loger.log(e);
			}
		}
		
		this.val.compileSchema(schema, config, loger);
	}
	
	public void compileSchema(TextSource schema, ProcessLoger loger) throws CancelException {
		try {
			this.compileSchema(schema, this.config, loger);
		} catch (TransformerConfigurationException e) {
			loger.log(e, true);
		} catch (FileNotFoundException e) {
			loger.log(e, true);
		}
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
	
	public TextSource executeFix(_QuickFix[] fixIds, TextSource svrlSource, TextSource input) throws TransformerConfigurationException{
		return this.exec.execute(fixIds, input, svrlSource, this.config);
	}

	public TextSource executeFix(_QuickFix[] fixIds, SVRLReport report, TextSource input) throws TransformerConfigurationException{
		return executeFix(fixIds, report.getSVRL(), input);
	}
	public TextSource executeFix(_QuickFix[] fixIds, SVRLReport report) throws TransformerConfigurationException{
		return this.exec.execute(fixIds, report, this.config);
	}
	
	public TextSource executeFix(_QuickFix[] fixIds) throws TransformerConfigurationException{
		return this.executeFix(fixIds, this.report);
	}
	
	public SVRLReport getReport(){
		return this.report;
	}
	
}
