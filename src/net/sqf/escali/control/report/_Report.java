package net.sqf.escali.control.report;

import java.io.File;
import java.util.ArrayList;

public interface _Report extends _MessageGroup {

	public abstract ArrayList<_Flag> getFlag();

	public abstract ArrayList<_Pattern> getPattern();
	
	public abstract _MessageGroup getGroup(String id);

	public abstract File getSchema();

	public abstract File getInstance();

}