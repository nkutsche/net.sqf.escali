package net.sqf.escali.control;

import java.io.IOException;
import java.util.ArrayList;

import javax.xml.xpath.XPathExpressionException;

import net.sqf.escali.control.report._Report;
import net.sqf.escali.control.report._SVRLMessage;
import net.sqf.escali.resources.EscaliRsourcesInterface;
import net.sqf.stringUtils.TextSource;
import net.sqf.utils.process.exceptions.CancelException;
import net.sqf.utils.process.log.DefaultProcessLoger;
import net.sqf.xmlUtils.exceptions.ValidationException;
import net.sqf.xmlUtils.exceptions.ValidationSummaryException;
import net.sqf.xmlUtils.exceptions.XSLTErrorListener;
import net.sqf.xmlUtils.xpath.ProcessNamespaces;
import net.sqf.xmlUtils.xsd.Xerces;

import org.xml.sax.SAXNotRecognizedException;
import org.xml.sax.SAXNotSupportedException;

public class SchematronBaseValidator {
	private Xerces xerces;
	private Escali internEscali;

	public SchematronBaseValidator(EscaliRsourcesInterface resource,
			Config config) throws SAXNotRecognizedException,
			SAXNotSupportedException, XSLTErrorListener,
			IOException, CancelException {
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
			report = internEscali.validate(schema, new DefaultProcessLoger()).getReport();
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
		private static final long serialVersionUID = 5177247209030123257L;
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
