package net.sqf.escali.resources;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.URL;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;

public class EscaliArchiveResources implements EscaliRsourcesInterface {
	private final String escaliFolder;
	private final String valFolder;
	private final String resolverFolder;
	private final String path;
	
	private Source getInputStream(String dir, String path) throws FileNotFoundException{
		String systemId = dir + path;
		Class<? extends EscaliArchiveResources> cl = this.getClass();
		InputStream ss = cl.getResourceAsStream(systemId);
		Source src = new StreamSource(ss);
		URL url = cl.getResource(systemId);
		src.setSystemId(url.toExternalForm());
		return src;
	}
	
	private Source[] getInputStream(String dir, String[] path) throws FileNotFoundException{
		Source[] isArr = new Source[path.length];
		for (int i = 0; i < path.length; i++) {
			isArr[i] = getInputStream(dir, path[i]);
		}
		return isArr;
	}
	
	public EscaliArchiveResources(String path){
		this.path = path;
		this.escaliFolder = path + "xsl/";
		this.valFolder = escaliFolder + "02_validator/";
		this.resolverFolder = escaliFolder +  "03_resolver/";
	}
	public EscaliArchiveResources(){
		this("/");
	}
	
	public Source getConfig() throws FileNotFoundException{
		return getInputStream(path, "config.xml");
	}
	
	public Source getSchemaInfo() throws FileNotFoundException{
		String compFolder = escaliFolder + "01_compiler/";
		return getInputStream(compFolder, "escali_compiler_0_getSchemaInfo.xsl");
	}
	
//	
//	Compiler
//	
	
	public Source[] getCompiler() throws FileNotFoundException{
		String compFolder = escaliFolder + "01_compiler/";
		String[] paths = {"escali_compiler_1_include.xsl", "escali_compiler_2_abstract-patterns.xsl", "escali_compiler_3_main.xsl"};
		return getInputStream(compFolder, paths);	
	}
	
	public Source[] getPreCompiler() throws FileNotFoundException{
		String compFolder = escaliFolder + "01_compiler/";
		String[] paths = {"escali_compiler_0_validate.xsl"};
		return getInputStream(compFolder, paths);	
	}
	
//	
//	Validator
//	
	
	public Source[] getValidator() throws FileNotFoundException{
		return getInputStream(valFolder, new String[]{"escali_validator_2_postprocess.xsl"});
	}
	
	public Source getSvrlPrinter(String type) throws FileNotFoundException{
		String prx = type.toLowerCase();
		return getInputStream(valFolder, "escali_validator_3_" + prx + "-report.xsl");
	}
	
//	
//	Resolver
//	
	
	public Source getResolver() throws FileNotFoundException{
		return getInputStream(resolverFolder, "escali_resolver_1_main.xsl");
	}

	@Override
	public Source getSchematronSchema() throws FileNotFoundException {
		return getInputStream(this.path + "schema/SQF/", "schematron-schema.xsd");
	}
	
	@Override
	public Source getSchematronForSchematron() throws FileNotFoundException {
		return getInputStream(this.path + "schema/SQF/", "sqf.sch");
	}

}
