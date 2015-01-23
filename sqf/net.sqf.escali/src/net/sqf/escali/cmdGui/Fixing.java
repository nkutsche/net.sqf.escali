package net.sqf.escali.cmdGui;

import java.io.IOException;

import javax.xml.transform.TransformerConfigurationException;

import net.sqf.escali.control.Escali;
import net.sqf.escali.control.SVRLReport;
import net.sqf.escali.control.report._ModelNode;
import net.sqf.escali.control.report._QuickFix;
import net.sqf.escali.control.report._Report;

public class Fixing {

	private Escali escali;
	private final SVRLReport report;
	
	public Fixing(SVRLReport report) {
		this.report = report;
	}
	
	public void executeFix(String fixId) throws TransformerConfigurationException, IOException {
		_Report reportObj = this.report.getReport();
		_ModelNode node = reportObj.getChildById(fixId);
		_QuickFix[] fixes;
		if(node != null && node instanceof _QuickFix){
			fixes = new _QuickFix[]{(_QuickFix) node};
		} else {
			fixes = new _QuickFix[]{};
		}
		escali.executeFix(fixes, this.report, this.report.getInput());
	}
}
