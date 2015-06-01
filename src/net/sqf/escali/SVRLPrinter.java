package net.sqf.escali;

import java.io.IOException;

import javax.xml.stream.XMLStreamException;

import net.sqf.stringUtils.TextSource;
import net.sqf.xmlUtils.parser.PositionalXMLReader;
import net.sqf.xmlUtils.staxParser.StringNode;
import net.sqf.xmlUtils.xpath.XPathReader;

import org.w3c.dom.Document;
import org.xml.sax.SAXException;

public class SVRLPrinter {
	private static XPathReader xpath = new XPathReader();
	private static PositionalXMLReader parser = new PositionalXMLReader();
	
	private final StringNode svrl;
	public SVRLPrinter(TextSource svrl) throws IOException, SAXException, XMLStreamException{
		this.svrl = new StringNode(svrl);
	}
	
	@Override
	public String toString() {
		return "SVRL report:\n" + this.svrl.getTextSource().toString();
	}
}
