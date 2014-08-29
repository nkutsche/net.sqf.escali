package net.sqf.escali.control.report;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;

import javax.xml.namespace.QName;
import javax.xml.xpath.XPathExpressionException;

import net.sqf.xmlUtils.staxParser.StringNode;
import net.sqf.xmlUtils.xpath.ProcessNamespaces;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;

public class ModelNodeFac {
	private _Report report;
	private int nodeCount = 0;
	private int flagCount = 0;
	private int patternCount = 0;
	private int ruleCount = 0;
	private int messageCount = 0;
	private int paraCount = 0;
	private int fixCount = 0;
	private int userEntryCount = 0;
	private int diagnosticCount = 0;
	private HashMap<String, _Flag> flags = new HashMap<String, _Flag>();
	public final static ModelNodeFac nodeFac = new ModelNodeFac();
	public final static QName ROOT_QNAME = new QName(ProcessNamespaces.ES_NS,
			"escali-reports");
	public final static QName PATTERN_QNAME = new QName(ProcessNamespaces.ES_NS,
			"pattern");
	public final static QName RULE_QNAME = new QName(ProcessNamespaces.ES_NS,
			"rule");
	public final static QName REPORT_QNAME = new QName(ProcessNamespaces.ES_NS,
			"report");
	public final static QName ASSERT_QNAME = new QName(ProcessNamespaces.ES_NS,
			"assert");
	public final static QName DIAGNOSTIC_QNAME = new QName(ProcessNamespaces.ES_NS,
			"es:diagnostics");
	public final static QName FLAG_QNAME = new QName("", "flag");
	public final static QName PARA_QNAME = new QName(ProcessNamespaces.SVRL_NS, "text");
	public final static QName QUICKFIX_QNAME = new QName(ProcessNamespaces.SQF_NS,
			"fix");
	public final static QName USERENTRY_QNAME = new QName(ProcessNamespaces.SQF_NS,
			"user-entry");

	private ModelNodeFac() {
	}

	public void setReport(_Report report) {
		flags = new HashMap<String, _Flag>();
		this.report = report;
		nodeCount = 0;
		flagCount = 0;
		patternCount = 0;
		ruleCount = 0;
		messageCount = 0;
		paraCount = 0;
		fixCount = 0;
		userEntryCount = 0;
		diagnosticCount = 0;
	}

	public _Report getReport(Node node, StringNode instance) throws DOMException,
			XPathExpressionException, URISyntaxException {
		return new Report(node, nodeCount++, instance);
	}


	public _ModelNode getNode(Node node, StringNode instance) throws DOMException,
			URISyntaxException, XPathExpressionException {
		String nsUri = node.getNamespaceURI();
		String localName = node.getLocalName();
		QName nodeName = new QName(nsUri, localName);
		if (nodeName.equals(ROOT_QNAME))
			return getReport(node, instance);
		if (nodeName.equals(PATTERN_QNAME))
			return getPattern(node, instance);
		if (nodeName.equals(RULE_QNAME))
			return getRule(node, instance);
		if (nodeName.equals(REPORT_QNAME))
			return getMessage(node, instance);
		if (nodeName.equals(ASSERT_QNAME))
			return getMessage(node, instance);
		if (nodeName.equals(DIAGNOSTIC_QNAME))
			return getDiagnostic(node);
		if (nodeName.equals(QUICKFIX_QNAME))
			return getQuickFix(node);
		if (nodeName.equals(USERENTRY_QNAME))
			return getUserEntry(node);
		else
			return getPara(node);
	}

	private _ModelNode getPattern(Node node, StringNode instance) throws DOMException,
			URISyntaxException, XPathExpressionException {
		return new Pattern(node, nodeCount++, patternCount++, instance);
	}

	private _ModelNode getRule(Node node, StringNode instance)
			throws DOMException, URISyntaxException, XPathExpressionException {
		return new Rule(node, nodeCount++, ruleCount++, instance);
	}

	private _ModelNode getMessage(Node node, StringNode instance) throws DOMException,
			URISyntaxException, XPathExpressionException {
		return new SVRLMessage(node, this.report, nodeCount++, messageCount++, instance);
	}

	private _ModelNode getQuickFix(Node node) throws DOMException,
			XPathExpressionException, URISyntaxException {
		return new QuickFix(node, nodeCount++, fixCount++);
	}

	private _ModelNode getUserEntry(Node node) throws DOMException,
			XPathExpressionException, URISyntaxException {
		return new UserEntry(node, nodeCount++, userEntryCount++);
	}

	public _Flag getFlag(Node node) throws DOMException, URISyntaxException {
		_Flag flag = new Flag(node, nodeCount++, flagCount++);
		if (flags.containsKey(flag.getName()))
			return flags.get(flag.getName());

		flags.put(flag.getName(), flag);
		flagCount++;
		return flag;
	}

	private _ModelNode getDiagnostic(Node node) throws DOMException,
			XPathExpressionException, URISyntaxException {
		return new Diagnostic(node, nodeCount++, diagnosticCount++);
	}

	private _ModelNode getPara(Node node) throws DOMException,
			URISyntaxException {
		return new Para(node, this.report, nodeCount++, paraCount++);
	}
}
