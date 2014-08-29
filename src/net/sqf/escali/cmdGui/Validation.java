package net.sqf.escali.cmdGui;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;

import javax.xml.stream.XMLStreamException;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.xpath.XPathExpressionException;

import org.xml.sax.SAXException;

import net.sqf.escali.control.Config;
import net.sqf.escali.control.Escali;
import net.sqf.escali.control.SVRLReport;
import net.sqf.escali.resources.EscaliArchiveResources;
import net.sqf.stringUtils.TextSource;

public class Validation {
	private Escali escali;
	
	public Validation(File schema, Config config) throws TransformerConfigurationException, IOException{
		this.escali = new Escali(config, new EscaliArchiveResources());
		this.escali.compileSchema(TextSource.readTextFile(schema));
	}
	
	public SVRLReport validate(File instance) throws IOException, XPathExpressionException, TransformerException, SAXException, URISyntaxException, XMLStreamException{
		TextSource textSource = TextSource.readTextFile(instance);
		return this.escali.validate(textSource);
	}
	
}
