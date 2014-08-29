package net.sqf.escali.control.report;

public interface _UserEntry extends _ModelNode {
	public String getName();
	public Object getValue();
	public void setValue(Object value);
	public void setValue(Object value, boolean useDefault);
	public boolean hasDefault();
	public boolean usingDefault();
	public boolean isValueValid();
	public String getDataType();
}
