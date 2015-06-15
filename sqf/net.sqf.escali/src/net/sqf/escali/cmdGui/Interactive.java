package net.sqf.escali.cmdGui;

import net.sqf.escali.control.SVRLReport;
import net.sqf.stringUtils.TextSource;

public class Interactive {
	
	
	private final SVRLReport report;

	public Interactive(SVRLReport report){
		this.report = report;
		
	}

	public void process() {
		TextSource ts = this.report.getFormatetReport(SVRLReport.TEXT_FORMAT);
		System.out.println(ts.toString());
		
	}
	

}
