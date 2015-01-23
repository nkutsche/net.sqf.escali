package net.sqf.escali.control;

import net.sqf.utils.process.exceptions.CancelException;

public interface EscaliReceiver {
	void viewReport(SVRLReport report);
	void setSchemaInfo(SchemaInfo schemaInfo);
	void compileSchemaFinish();
	void viewException(Exception e) throws CancelException;
}
