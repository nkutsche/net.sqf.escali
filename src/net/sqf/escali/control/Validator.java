package net.sqf.escali.control;

import java.io.FileNotFoundException;
import java.util.ArrayList;

import javax.xml.transform.Source;

import net.sqf.escali.resources.EscaliRsourcesInterface;
import net.sqf.stringUtils.TextSource;
import net.sqf.utils.process.log.DefaultProcessLoger;
import net.sqf.utils.process.log.ProcessLoger;
import net.sqf.xmlUtils.exceptions.XSLTErrorListener;
import net.sqf.xmlUtils.xslt.Parameter;
import net.sqf.xmlUtils.xslt.XSLTPipe;

public class Validator {
	private TextSource svrl;

	private XSLTPipe precompilerPipe;
	private XSLTPipe compilerPipe;
	private XSLTPipe validatorPipe;
	
	private TextSource schema;

	private final EscaliRsourcesInterface resource;
	
	
	public Validator(EscaliRsourcesInterface resource) throws XSLTErrorListener, FileNotFoundException{
		this.resource = resource;
		compilerPipe = new XSLTPipe("Escali compiling");
		Source[] compiler = resource.getCompiler();
		compilerPipe.addStep(compiler);
		

		precompilerPipe = new XSLTPipe("Escali pre compiling");
		Source[] precompiler = resource.getPreCompiler();
		precompilerPipe.addStep(precompiler);
	}
	
	protected TextSource preCompileSchema(TextSource schema, Config config, ProcessLoger loger) {
		loger.log("Create validator");
		return precompilerPipe.pipe(schema, config.createCompilerParams(), new DefaultProcessLoger());
	}

	protected void compileSchema(TextSource schema, Config config, ProcessLoger loger) throws XSLTErrorListener, FileNotFoundException {
		this.schema = schema;
		loger.log("Create validator");
		TextSource validator = compilerPipe.pipe(schema, config.createCompilerParams());
		loger.log("Implement validator");
		createValidatorPipe(validator);
		
	}
	
	private void createValidatorPipe(TextSource validator1) throws XSLTErrorListener, FileNotFoundException{
		this.validatorPipe = new XSLTPipe("Escali validate");
		validatorPipe.addStep(validator1);
		validatorPipe.addStep(resource.getValidator());
		
		
	}
	
	
	protected void validateInstance(TextSource xml, ArrayList<Parameter> params, ProcessLoger logger){
		this.svrl = validatorPipe.pipe(xml, params, logger);
	}
	
	
	
	protected TextSource getSvrl(){
		return this.svrl;
	}

	public TextSource getSchema() {
		// TODO Auto-generated method stub
		return this.schema;
	}
	
}
