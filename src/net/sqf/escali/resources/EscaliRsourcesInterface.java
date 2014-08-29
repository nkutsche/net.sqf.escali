package net.sqf.escali.resources;

import java.io.FileNotFoundException;
import java.io.InputStream;

import javax.xml.transform.Source;

public interface EscaliRsourcesInterface {
	public Source getConfig() throws FileNotFoundException;
	public Source getSchemaInfo() throws FileNotFoundException;
	public Source[] getCompiler() throws FileNotFoundException;
	public Source[] getValidator() throws FileNotFoundException;
	public Source getSvrlPrinter(String type) throws FileNotFoundException;
	public Source getResolver() throws FileNotFoundException;
}
