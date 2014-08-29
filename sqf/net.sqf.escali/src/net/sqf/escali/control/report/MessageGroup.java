package net.sqf.escali.control.report;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Iterator;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;

public class MessageGroup extends ModelNode implements _MessageGroup {

	MessageGroup(Node node, int svrlIdx) throws DOMException,
			URISyntaxException {
		super(node, svrlIdx);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see model.messages.nodes._MessageGroup#getLevelCounts()
	 */
	@Override
	public int[] getLevelCounts() {
		int[] levelCounts = new int[_SVRLMessage.LEVEL_COUNT];
		ArrayList<_SVRLMessage> children = this.getMessages();
		for (Iterator<_SVRLMessage> iterator = children.iterator(); iterator
				.hasNext();) {
			_SVRLMessage modelNode = iterator.next();
			if (modelNode instanceof SVRLMessage) {
				SVRLMessage msg = (SVRLMessage) modelNode;
				int level = (int) msg.getErrorLevel();
				levelCounts[level]++;
			}
		}
		return levelCounts;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see model.messages.nodes._MessageGroup#getMessages()
	 */
	@Override
	public ArrayList<_SVRLMessage> getMessages(int minErrorLevel,
			int maxErrorLevel) {
		ArrayList<_SVRLMessage> messages = new ArrayList<_SVRLMessage>();
		ArrayList<_ModelNode> children = this.getChildren();
		for (Iterator<_ModelNode> iterator = children.iterator(); iterator
				.hasNext();) {
			_ModelNode modelNode = iterator.next();
			if (modelNode instanceof MessageGroup) {
				_MessageGroup group = (_MessageGroup) modelNode;
				messages.addAll(group.getMessages(minErrorLevel, maxErrorLevel));

			} else if (modelNode instanceof SVRLMessage) {
				SVRLMessage msg = (SVRLMessage) modelNode;
				if (msg.getErrorLevel() >= minErrorLevel && msg.getErrorLevel() <= maxErrorLevel)
					messages.add(msg);
			}
		}
		return messages;
	}

	@Override
	public ArrayList<_SVRLMessage> getMessages() {
		return getMessages(0, SVRLMessage.LEVEL_COUNT);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see model.messages.nodes._MessageGroup#getMessageCount()
	 */
	@Override
	public int getMessageCount() {
		return this.getMessages().size();
	}
	
	@Override
	public double getMaxErrorLevel(){
		ArrayList<_SVRLMessage> messages = getMessages();
		double maxLevel = -1.0;
		for (Iterator<_SVRLMessage> iterator = messages.iterator(); iterator
				.hasNext();) {
			double msgLevel = iterator.next().getErrorLevel();
			maxLevel = msgLevel > maxLevel ? msgLevel : maxLevel;
		}
		return maxLevel;
	}
	
	@Override
	public double getErrorLevel() {
		ArrayList<_SVRLMessage> messages = getMessages();
		double sumWeight = 0.0;
		for (Iterator<_SVRLMessage> iterator = messages.iterator(); iterator
				.hasNext();) {
			_SVRLMessage msg = iterator.next();
			sumWeight += msg.getErrorWeight();
		}
		return sumWeight / messages.size();
	}

}
