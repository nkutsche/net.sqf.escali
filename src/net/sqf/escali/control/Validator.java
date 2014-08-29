package net.sqf.escali.control;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerConfigurationException;

import net.sqf.escali.resources.EscaliFileResources;
import net.sqf.escali.resources.EscaliRsourcesInterface;
import net.sqf.stringUtils.TextSource;
import net.sqf.xmlUtils.xpath.ProcessNamespaces;
import net.sqf.xmlUtils.xslt.Parameter;
import net.sqf.xmlUtils.xslt.XSLTPipe;

public class Validator {
	private TextSource svrl;
	
	private XSLTPipe compilerPipe;
	private XSLTPipe validatorPipe;
	
	private TextSource schema;

	private final EscaliRsourcesInterface resource;
	
	public Validator(EscaliRsourcesInterface resource) throws TransformerConfigurationException, FileNotFoundException{
		this.resource = resource;
		compilerPipe = new XSLTPipe();
		Source[] compiler = resource.getCompiler();
		compilerPipe.addStep(compiler);
	}

	protected void compileSchema(TextSource schema, Config config) throws TransformerConfigurationException, FileNotFoundException {
		this.schema = schema;
		createValidatorPipe(compilerPipe.pipe(schema, config.createCompilerParams()));
		
	}
	
	private void createValidatorPipe(TextSource validator1) throws TransformerConfigurationException, FileNotFoundException{
		this.validatorPipe = new XSLTPipe();
		validatorPipe.addStep(validator1);
		validatorPipe.addStep(resource.getValidator());
		
		
	}
	
	
	protected void validateInstance(TextSource xml, ArrayList<Parameter> params){
		this.svrl =  validatorPipe.pipe(xml, params);
	}
	
	
	
	protected TextSource getSvrl(){
		return this.svrl;
	}

	public TextSource getSchema() {
		// TODO Auto-generated method stub
		return this.schema;
	}
	
}
