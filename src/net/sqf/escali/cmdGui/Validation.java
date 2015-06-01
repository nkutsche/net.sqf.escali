package net.sqf.escali.cmdGui;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.Scanner;

import javax.xml.stream.XMLStreamException;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.xpath.XPathExpressionException;

import org.xml.sax.SAXException;

import net.sqf.escali.control.Config;
import net.sqf.escali.control.Escali;
import net.sqf.escali.control.EscaliReceiver;
import net.sqf.escali.control.SVRLReport;
import net.sqf.escali.control.report._ModelNode;
import net.sqf.escali.control.report._QuickFix;
import net.sqf.escali.control.report._Report;
import net.sqf.escali.resources.EscaliArchiveResources;
import net.sqf.stringUtils.TextSource;
import net.sqf.utils.process.exceptions.CancelException;
import net.sqf.utils.process.log.DefaultProcessLoger;
import net.sqf.utils.process.log.ProcessLoger;
import net.sqf.xmlUtils.exceptions.XSLTErrorListener;

public class Validation {
	private Escali escali;
	private Scanner cmdInput = new Scanner(System.in);
	
	public Validation(File schema, Config config, ProcessLoger logger) throws XSLTErrorListener, IOException, CancelException{
		this.escali = new Escali(config, new EscaliArchiveResources());
		this.escali.compileSchema(TextSource.readTextFile(schema), logger);
	}
	
	public SVRLReport validate(File instance) throws IOException, XPathExpressionException, XSLTErrorListener, SAXException, URISyntaxException, XMLStreamException{
		TextSource textSource = TextSource.readTextFile(instance);
		return this.escali.validate(textSource, new DefaultProcessLoger());
	}
	
	public void executeFix(String fixId) throws XSLTErrorListener, IOException {
		_Report reportObj = this.escali.getReport().getReport();
		_ModelNode node = reportObj.getChildById(fixId);
		_QuickFix[] fixes;
		if(node != null && node instanceof _QuickFix){
			fixes = new _QuickFix[]{(_QuickFix) node};
		} else {
			fixes = new _QuickFix[]{};
		}
//		escali.executeFix(fixes);
	}
	
	public void interactive() {
		SVRLReport report = this.escali.getReport();
		TextSource ts = report.getFormatetReport(SVRLReport.TEXT_FORMAT);
		System.out.println(ts.toString());
		System.out.println("Choose your quickfix:");
		
		int sel = Integer.parseInt(cmdInput.next()) - 1;
		
		
	}
	
}
