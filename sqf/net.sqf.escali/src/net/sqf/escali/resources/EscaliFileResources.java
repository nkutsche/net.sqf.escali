package net.sqf.escali.resources;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;


public class EscaliFileResources implements EscaliRsourcesInterface {
	private final File baseFolder;
	private final File escaliFolder;
	private final File valFolder;
	private final File resolverFolder;
	
	public File defaultTempFolder;
	
	private Source getInputStream(File dir, String path) throws FileNotFoundException{
		Source src = new StreamSource(new File(dir, path));
		
		return src;
	}
	
	private Source[] getInputStream(File dir, String[] path) throws FileNotFoundException{
		Source[] isArr = new Source[path.length];
		for (int i = 0; i < path.length; i++) {
			isArr[i] = getInputStream(dir, path[i]);
		}
		return isArr;
	}
	
	public EscaliFileResources(File baseDir) {
		this.baseFolder = baseDir;
		this.escaliFolder = new File(baseFolder, "xml/xsl");
		this.defaultTempFolder = new File(baseFolder, "../temp");
		this.valFolder = new File(escaliFolder, "02_validator");
		this.resolverFolder = new File(escaliFolder, "03_resolver");
	}
	
	public Source getConfig() throws FileNotFoundException{
		return getInputStream(baseFolder, "META-INF/config.xml");
	}
	
	public Source getSchemaInfo() throws FileNotFoundException{
		File compFolder = new File(escaliFolder, "01_compiler");
		return getInputStream(compFolder, "escali_compiler_0_getSchemaInfo.xsl");
	}
	
//	
//	Compiler
//	
	
	public Source[] getCompiler() throws FileNotFoundException{
		File compFolder = new File(escaliFolder, "01_compiler");
		String[] paths = {"escali_compiler_1_include.xsl", "escali_compiler_2_abstract-patterns.xsl", "escali_compiler_3_main.xsl"};
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
}
