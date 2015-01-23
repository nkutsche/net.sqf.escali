package net.sqf.escali.control;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.util.ArrayList;

import javax.xml.stream.XMLStreamException;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.xpath.XPathExpressionException;

import org.w3c.dom.DOMException;
import org.xml.sax.SAXException;
import org.xml.sax.SAXNotRecognizedException;
import org.xml.sax.SAXNotSupportedException;

import net.sqf.escali.control.report.ModelNodeFac;
import net.sqf.escali.control.report._Report;
import net.sqf.escali.control.report._SVRLMessage;
import net.sqf.escali.resources.EscaliRsourcesInterface;
import net.sqf.stringUtils.TextSource;
import net.sqf.utils.process.exceptions.CancelException;
import net.sqf.utils.process.log.DefaultProcessLoger;
import net.sqf.xmlUtils.exceptions.ValidationException;
import net.sqf.xmlUtils.exceptions.ValidationSummaryException;
import net.sqf.xmlUtils.staxParser.StringNode;
import net.sqf.xmlUtils.xpath.ProcessNamespaces;
import net.sqf.xmlUtils.xsd.Xerces;
import net.sqf.xmlUtils.xslt.Parameter;

public class SchematronBaseValidator {
	private Xerces xerces;
	private EscaliRsourcesInterface resource;
	private Escali internEscali;

	public SchematronBaseValidator(EscaliRsourcesInterface resource,
			Config config) throws SAXNotRecognizedException,
			SAXNotSupportedException, TransformerConfigurationException,
			IOException, CancelException {
		this.resource = resource;
		xerces = new Xerces(ProcessNamespaces.SCH_NS,
				resource.getSchematronSchema());
		this.internEscali = new Escali(config, resource, false);
		TextSource sqfSch = TextSource.readXmlFile(resource
				.getSchematronForSchematron());
		internEscali.compileSchema(sqfSch, new DefaultProcessLoger());

	}

	public void validate(TextSource schema) throws ValidationSummaryException {
		ValidationSummaryException vse = new ValidationSummaryException("Validation of schema " + schema.getFile().getAbsolutePath(), new ArrayList<ValidationException>());
		try{
			xerces.validateSource(schema);
		} catch (ValidationSummaryException e){
			vse.addException(e);
		} catch (Exception e){
			vse.addException(e);
		}
		_Report report;
		try {
			report = internEscali.validate(schema).getReport();
			double mel = report.getMaxErrorLevel();
			if(mel >= _SVRLMessage.LEVEL_ERROR){
				ArrayList<_SVRLMessage> errors = report.getMessages(_SVRLMessage.LEVEL_ERROR, _SVRLMessage.LEVEL_FATAL_ERROR);
				vse.addException(getValidationSummary(report.getName(), errors));
			}
		} catch (Exception e) {
			vse.addException(e);
		}
		ArrayList<ValidationException> exList = vse.getExceptionList();
		if(exList.size() > 0){
			throw vse;
		}
	}
	
	private ValidationSummaryException getValidationSummary(String title, ArrayList<_SVRLMessage> msgs){
		ArrayList<ValidationException> velist = new ArrayList<ValidationException>();
		for (_SVRLMessage msg : msgs) {
			velist.add(new SVRLException(msg));
		}
		return new ValidationSummaryException(title, velist);
	}
	
	
	private static class SVRLException extends ValidationException {
		private static int getLineNumber(_SVRLMessage msg){
			try {
				return msg.getLocationInIstance().getStart().getLineNumber();
			} catch (XPathExpressionException e) {
				return -1;
			}
		}
		private static int getColumnNumber(_SVRLMessage msg){
			try {
				return msg.getLocationInIstance().getStart().getColumnNumber();
			} catch (XPathExpressionException e) {
				return -1;
			}
		}
		public SVRLException(_SVRLMessage msg){
			super(msg.getName(), 
					msg.getInstanceFile().toURI().toString(), 
					getLineNumber(msg), 
					getColumnNumber(msg),
					ValidationException.TYPE_SCHEMATRON);
		}
	}
}
