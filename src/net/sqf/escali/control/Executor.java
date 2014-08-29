package net.sqf.escali.control;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;

import javax.xml.stream.XMLStreamException;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.xpath.XPathExpressionException;

import org.xml.sax.SAXException;

import net.sqf.escali.control.report._QuickFix;
import net.sqf.escali.control.report._UserEntry;
import net.sqf.escali.resources.EscaliFileResources;
import net.sqf.escali.resources.EscaliRsourcesInterface;
import net.sqf.stringUtils.TextSource;
import net.sqf.xmlUtils.xpath.ProcessNamespaces;
import net.sqf.xmlUtils.xslt.Parameter;
import net.sqf.xmlUtils.xslt.XSLTPipe;
import net.sqf.xsm.operations.PositionalReplace;

public class Executor {
	
	private XSLTPipe resolver = new XSLTPipe();
	
	public Executor(EscaliRsourcesInterface resource) throws TransformerConfigurationException, FileNotFoundException{
		resolver.addStep(resource.getResolver());
	}
	
	public TextSource execute(_QuickFix[] fixes, SVRLReport report, TextSource input, Config config) throws TransformerConfigurationException{
		String[] ids = new String[fixes.length];
		ArrayList<Parameter> ueParams = new ArrayList<Parameter>();
		for (int i = 0; i < ids.length; i++) {
			ids[i] = fixes[i].getId();
			_UserEntry[] settedUEs = fixes[i].getSettedParameter();
			for (_UserEntry entry : settedUEs) {
				ueParams.add(new Parameter(entry.getId(), ProcessNamespaces.SQF_NS, entry.getValue()));
			}
		}
		
		XSLTPipe manipulator = new XSLTPipe();
		ArrayList<Parameter> params = new ArrayList<Parameter>();
		params.add(new Parameter("id", ids));
		TextSource resolverXSL = resolver.pipe(report.getSVRL(), params); 
		manipulator.addStep(resolverXSL, ueParams);
		TextSource resolverResult = manipulator.pipe(input, config.createManipulatorParams());
		
		if(config.isXmlSaveMode()){
			try {
				PositionalReplace pr = new PositionalReplace(resolverResult, input);
				return pr.getSource();
			} catch (IOException e) {
				return input;
			} catch (SAXException e) {
				return input;
			} catch (XMLStreamException e) {
				return input;
			} catch (XPathExpressionException e) {
				return input;
			}
		} else {
			return resolverResult;
		}
//		return resolverXSL;
	}
}
