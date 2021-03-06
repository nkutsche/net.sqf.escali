package net.sqf.escali.control;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;

import javax.xml.stream.XMLStreamException;
import javax.xml.xpath.XPathExpressionException;

import net.sqf.escali.control.report._QuickFix;
import net.sqf.escali.control.report._UserEntry;
import net.sqf.escali.resources.EscaliRsourcesInterface;
import net.sqf.stringUtils.TextSource;
import net.sqf.utils.process.exceptions.CancelException;
import net.sqf.xmlUtils.exceptions.XSLTErrorListener;
import net.sqf.xmlUtils.xpath.ProcessNamespaces;
import net.sqf.xmlUtils.xslt.Parameter;
import net.sqf.xmlUtils.xslt.XSLTPipe;
import net.sqf.xsm.operations.PositionalReplace;

import org.xml.sax.SAXException;

public class Executor {
	
	private XSLTPipe extractor = new XSLTPipe("");
	
	public Executor(EscaliRsourcesInterface resource) throws XSLTErrorListener, FileNotFoundException{
		extractor.addStep(resource.getResolver());
	}

//	public TextSource execute(_QuickFix[] fixes, SVRLReport report, Config config) throws XSLTErrorListener{
//		return execute(fixes, report.getInput(), report.getSVRL(), config);
//	}
	public TextSource execute(_QuickFix[] fixes, TextSource input, TextSource svrl, Config config) throws XSLTErrorListener{
		String[] ids = new String[fixes.length];
		ArrayList<Parameter> ueParams = new ArrayList<Parameter>();
		for (int i = 0; i < ids.length; i++) {
			ids[i] = fixes[i].getId();
			_UserEntry[] settedUEs = fixes[i].getSettedParameter();
			for (_UserEntry entry : settedUEs) {
				ueParams.add(new Parameter(entry.getId(), ProcessNamespaces.SQF_NS, entry.getValue()));
			}
		}
		XSLTPipe manipulator = new XSLTPipe("", new XSLTErrorListener());
		ArrayList<Parameter> params = new ArrayList<Parameter>();
		params.add(new Parameter("id", ids));
		params.add(new Parameter("markChanges", !config.getChangePrefix().equals("")));
		TextSource extractorXSL = extractor.pipe(svrl, params); 
		manipulator.addStep(extractorXSL, ueParams);
		TextSource extractorResult = manipulator.pipe(input, config.createManipulatorParams());
		
		if(config.isXmlSaveMode()){
			try {
				PositionalReplace pr = new PositionalReplace(extractorResult, input);
				return pr.getSource();
			} catch (IOException e) {
				return input;
			} catch (SAXException e) {
				return input;
			} catch (XMLStreamException e) {
				return input;
			} catch (XPathExpressionException e) {
				return input;
			} catch (CancelException e) {
				return input;
			}
		} else {
			return extractorResult;
		}
//		return extractorXSL;
	}
}
