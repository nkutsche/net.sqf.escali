package net.sqf.escali.control.report;

import java.net.URI;
import java.util.ArrayList;

public interface _ModelNode {
	void setId(String id);
	String toString();
	_ModelNode getParent();
	String getBaseUri();
	ArrayList<_ModelNode> getChildren();
	String getId();
	void setName(String name);
	void setParent(_ModelNode parent);
	void addChild(_ModelNode child);
	boolean hasParent();
	void addChild(ArrayList<_ModelNode> children);
	int getIndex();
	int getSvrlIndex();
	URI getIcon();
	URI getLink();
	boolean hasIcon();
	boolean hasLink();
	String getName();
	int getChildCount();
	double getErrorLevel();
	
	ArrayList<_ModelNode> getChildById(String[] ids);
	_ModelNode getChildById(String id);


}
