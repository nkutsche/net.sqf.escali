package net.sqf.escali.control.report;

import java.util.ArrayList;

public interface _MessageGroup extends _ModelNode{

	public abstract int[] getLevelCounts();

	public abstract ArrayList<_SVRLMessage> getMessages();
	
	public abstract ArrayList<_SVRLMessage> getMessages(int minErrorLevel, int maxErrorLevel);

	public abstract int getMessageCount();

	public abstract double getErrorLevel();

	public abstract double getMaxErrorLevel();

}