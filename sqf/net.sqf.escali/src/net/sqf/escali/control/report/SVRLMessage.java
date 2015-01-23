package net.sqf.escali.control.report;

import java.io.File;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Iterator;

import javax.xml.stream.Location;
import javax.xml.xpath.XPathExpressionException;

import net.sqf.escali.control.SVRLReport;
import net.sqf.xmlUtils.parser.PositionalXMLHandler;
import net.sqf.xmlUtils.staxParser.NodeInfo;
import net.sqf.xmlUtils.staxParser.PositionalXMLReader;
import net.sqf.xmlUtils.staxParser.StringNode;
import net.sqf.xmlUtils.xpath.ProcessNamespaces;
import net.sqf.xmlUtils.xpath.XPathReader;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class SVRLMessage extends ModelNode implements _SVRLMessage {

	private String location;
	private double errorLevel;
	private _QuickFix defaultFix;
	private _Flag flag;
	private _Report report;
	private final StringNode instance;

	public static ArrayList<_SVRLMessage> getSubsequence(
			ArrayList<_ModelNode> nodes) {
		ArrayList<_SVRLMessage> subsequence = new ArrayList<_SVRLMessage>();
		for (Iterator<_ModelNode> iterator = nodes.iterator(); iterator
				.hasNext();) {
			_ModelNode modelNode = iterator.next();
			if (modelNode instanceof SVRLMessage) {
				SVRLMessage subNode = (SVRLMessage) modelNode;
				subsequence.add(subNode);
			}
		}
		return subsequence;
	}

	SVRLMessage(Node messageNode, _Report report, int svrlIdx, int Index, StringNode instance) throws DOMException, URISyntaxException,
			XPathExpressionException {
		super(messageNode, svrlIdx);
		this.instance = instance;
		this.setId(SVRLReport.XPR.getAttributValue(messageNode, "id"));
		this.setIndex(Index);
		this.report = report;

		// S E T N A M E
		XPathReader xpathreader = new XPathReader();
		NodeList texte = xpathreader.getNodeSet("es:text", messageNode);
		String message = "";
		for (int i = 0; i < texte.getLength(); i++) {
			message += texte.item(i).getTextContent();
			if (i + 1 < texte.getLength())
				message += " ";
		}
		this.setName(message);

		// L I N E N U M B E R
		this.location = SVRLReport.XPR.getAttributValue(messageNode, "location");

		// E R R O R L E V E L (@role)
		String levelValue = SVRLReport.XPR
				.getAttributValue(messageNode, "role");
		this.errorLevel = levelValue.equals("") ? _SVRLMessage.LEVEL_DEFAULT : Double.parseDouble(levelValue);
		
		// D I A G N O S T I C S
		NodeList diagnNodes = xpathreader.getNodeSet(
				"es:diagnostics", messageNode);

		for (int i = 0; i < diagnNodes.getLength(); i++) {
			this.addChild(ModelNodeFac.nodeFac.getNode(diagnNodes.item(i), instance));
		}

		// Q U I C K F I X E S
		NodeList fixNodes = xpathreader.getNodeSet("sqf:fix", messageNode);
		Node defFixNode = xpathreader.getNode("sqf:fix[@default='true']", messageNode);

		for (int i = 0; i < fixNodes.getLength(); i++) {
			Node fixNode = fixNodes.item(i);
			_QuickFix fix = (_QuickFix) ModelNodeFac.nodeFac.getNode(fixNode, instance);
			this.addChild(fix);
			
			if(defFixNode == fixNode){
				this.defaultFix = fix;
			}
		}

		// F L A G S
		Node flagNode = messageNode.getAttributes().getNamedItem("flag");
		if (flagNode != null){
			this.flag = ModelNodeFac.nodeFac.getFlag(flagNode);
			flag.addChild(this);
		}
		
		
		this.setName(this.getName());
	}


	@Override
	public void addChild(_ModelNode child) {
		if (child instanceof _Flag){
			this.flag = (_Flag) child;
		} else {
			super.addChild(child);
			if (child instanceof QuickFix) {
				report.addChild(child);
			}
		}
	}
	
	@Override
	public boolean hasQuickFixes(){
		return getQuickFixes().length > 0;
	}

	@Override
	public _QuickFix[] getQuickFixes() {
		ArrayList<_ModelNode> children = this.getChildren();
		ArrayList<_QuickFix> fixes = QuickFix.getSubsequence(children);
		return fixes.toArray(new _QuickFix[fixes.size()]);
	}
	
	@Override
	public _QuickFix getQuickFix(String fixId) {
		ArrayList<_QuickFix> fixList = QuickFix.getSubsequence(this.getChildById(new String[]{fixId}));
		return fixList.get(0);
	}



	@Override
	public String getPatternId() {
		// TODO Auto-generated method stub
		return this.getParent().getParent().getId();
	}

	@Override
	public String getRuleId() {
		// TODO Auto-generated method stub
		return this.getParent().getId();
	}

	@Override
	public _QuickFix getDefaultFix() {
		return this.defaultFix;
	}
	
	@Override
	public boolean hasDefaultFix() {
		return this.defaultFix != null;
	}

	@Override
	public String getLocation() {
		return this.location;
	}
	
	@Override
	public NodeInfo getLocationInIstance() throws XPathExpressionException{
		return this.instance.getNodeInfo(this.getLocation());
	}

	@Override
	public File getInstanceFile(){
		return this.instance.getFile();
	}


	@Override
	public double getErrorLevel() {
		return doubleToLevel(this.errorLevel);
	}
	
	@Override
	public int getErrorLevelInt() {
		return doubleToLevel(this.errorLevel);
	}
	

	@Override
	public double getErrorWeight() {
		return this.errorLevel;
	}

	@Override
	public _Flag getFlag() {
		return this.flag;
	}

	@Override
	public ArrayList<Diagnostic> getDiagnostics() {
		ArrayList<_ModelNode> children = this.getChildren();
		ArrayList<Diagnostic> diagn = Diagnostic.getSubsequence(children);
		return diagn;
	}
	
	static public int doubleToLevel(double value) {
		int levelCount = _SVRLMessage.LEVEL_COUNT;
		value = value * levelCount;
		value = Math.floor(value);
		return (int) value;
	}
	public static String levelToString(int i) {
		return _SVRLMessage.LEVEL_NAMES[i];
	}
	public static String levelToString(int[] levels){
		
		String summary = "";
		for (int i = levels.length - 1; i >= 0 ; i--) {
			if (levels[i] > 0) {
				summary += levels[i] + " " + levelToString(i);
				summary += levels[i] > 1 ? "s" : "";
				summary += i  > 0 ? ", " : "";
			}
		}
		return summary;
	}


	
	@Override
	public String toString() {
		try {
			return this.getLocationInIstance().getStart().getLineNumber() + ": " + this.getName();
		} catch (XPathExpressionException e) {
			return this.getName();
		}
	}
}
