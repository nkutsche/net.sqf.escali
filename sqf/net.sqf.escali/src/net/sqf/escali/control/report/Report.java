package net.sqf.escali.control.report;

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;

import javax.xml.xpath.XPathExpressionException;

import net.sqf.escali.control.SVRLReport;
import net.sqf.xmlUtils.staxParser.StringNode;
import net.sqf.xmlUtils.xpath.ProcessNamespaces;
import net.sqf.xmlUtils.xpath.XPathReader;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class Report extends MessageGroup implements _Report {
	private final File schema;
	private final File instance;
	private final HashMap<String, ArrayList<_QuickFix>> fixByQuickFix = new HashMap<String, ArrayList<_QuickFix>>();
	private final HashMap<String, ArrayList<_QuickFix>> fixByMessage = new HashMap<String, ArrayList<_QuickFix>>();

	public static ArrayList<Report> getSubsequence(ArrayList<_ModelNode> nodes) {
		ArrayList<Report> subsequence = new ArrayList<Report>();
		for (Iterator<_ModelNode> iterator = nodes.iterator(); iterator
				.hasNext();) {
			_ModelNode modelNode = iterator.next();
			if (modelNode instanceof Report) {
				Report subNode = (Report) modelNode;
				subsequence.add(subNode);
			}
		}
		return subsequence;
	}
	

	protected Report(Node report, int svrlIdx, StringNode instance) throws DOMException, URISyntaxException,
			XPathExpressionException {
		super(report, svrlIdx);
		ModelNodeFac.nodeFac.setReport(this);
		this.setId("report");
		this.setIndex(0);

//		S E T   S C H E M A
		XPathReader xpathreader = new XPathReader();
		String schemaStr = xpathreader.getString("es:meta/es:schema", report);
		URI schemaUri = new URI(schemaStr);
		this.schema = new File(schemaUri);

//		S E T   I N S T A N C E
		String instanceStr = xpathreader.getString("es:meta/es:instance", report);
		URI instanceUri = new URI(instanceStr);
		this.instance = new File(instanceUri);
		
//		S E T   T I T L E
		String manualTitle = xpathreader.getString("es:meta/es:title", report);
		if (!manualTitle.equals(""))
			setName(manualTitle);
		else
			setName("Report " + this.schema.getName() + " | " + this.instance.getName());
		

		// S E T   C H I L D S
		NodeList nodes = xpathreader.getNodeSet("es:pattern", report);
		for (int i = 0; i < nodes.getLength(); i++) {
			Node pattern = nodes.item(i);
			NodeList paras = xpathreader.getNodeSet("es:meta/es:text", pattern);
			
			for (int j = 0; j < paras.getLength(); j++) {
				this.addChild(ModelNodeFac.nodeFac.getNode(paras.item(j), instance));
			}
			this.addChild(ModelNodeFac.nodeFac.getNode(pattern, instance));
		}

	}

	/* (non-Javadoc)
	 * @see model.messages.nodes._Report#getFlag()
	 */
	@Override
	public ArrayList<_Flag> getFlag() {
		HashSet<_Flag> flagSet = new HashSet<_Flag>();
		ArrayList<_Flag> flagList = new ArrayList<_Flag>();
		ArrayList<_SVRLMessage> messages = this.getMessages();
		for (Iterator<_SVRLMessage> iterator = messages.iterator(); iterator.hasNext();) {
			_SVRLMessage message = iterator.next();
			if(message.getFlag() != null)
				flagSet.add(message.getFlag());
		}
		flagList.addAll(flagSet);
		return flagList;
	}

	/* (non-Javadoc)
	 * @see model.messages.nodes._Report#getPattern()
	 */
	@Override
	public ArrayList<_Pattern> getPattern() {
		ArrayList<_ModelNode> children = this.getChildren();
		ArrayList<_Pattern> patterns = Pattern.getSubsequence(children);
		return patterns;
	}
	
	@Override
	public _MessageGroup getGroup(String id){
		ArrayList<_Pattern> patterns = this.getPattern();
		for (Iterator<_Pattern> iterator = patterns.iterator(); iterator.hasNext();) {
			_Pattern pattern = iterator.next();
			if (pattern.getId().equals(id)) {
				return pattern;
			} else {
				_MessageGroup rule = pattern.getGroup(id);
				if(rule != null)
					return rule;
			}
		}
		return null;
	}

	@Override
	public File getSchema() {
		return this.schema;
	}

	@Override
	public void addChild(_ModelNode child) {
		if(child instanceof QuickFix){
			QuickFix fix = (QuickFix) child;
			this.addFix(fix);
			return;	
		}
		super.addChild(child);
	}
	private void addFix(QuickFix fix){
		String fixId = fix.getFixId();
		String msgFixId = fix.getMessageId() + fixId;
		if(!fixByQuickFix.containsKey(fixId)){
			fixByQuickFix.put(fixId, new ArrayList<_QuickFix>());
		}
		ArrayList<_QuickFix> relFixes = fixByQuickFix.get(fixId);
		for (Iterator<_QuickFix> iterator = relFixes.iterator(); iterator.hasNext();) {
			_QuickFix relFix = iterator.next();
			relFix.addFixRelFix(fix);
			fix.addFixRelFix(relFix);
		}
		relFixes.add(fix);
		
		if(!fixByMessage.containsKey(msgFixId)){
			fixByMessage.put(msgFixId, new ArrayList<_QuickFix>());
		}
		ArrayList<_QuickFix> msgRelFixes = fixByMessage.get(msgFixId);
		for (Iterator<_QuickFix> iterator = msgRelFixes.iterator(); iterator.hasNext();) {
			_QuickFix relFix = iterator.next();
			relFix.addMsgRelFix(fix);
			fix.addMsgRelFix(relFix);
		}
		msgRelFixes.add(fix);
	}

	@Override
	public File getInstance() {
		return this.instance;
	}

}
