package net.sqf.escali.control.report;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Iterator;

import javax.xml.xpath.XPathExpressionException;

import net.sqf.escali.control.SVRLReport;
import net.sqf.xmlUtils.xpath.XPathReader;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class UserEntry extends MessageGroup implements _UserEntry {

	public static ArrayList<_UserEntry> getSubsequence(
			ArrayList<_ModelNode> nodes) {
		ArrayList<_UserEntry> subsequence = new ArrayList<_UserEntry>();
		for (Iterator<_ModelNode> iterator = nodes.iterator(); iterator
				.hasNext();) {
			_ModelNode modelNode = iterator.next();
			if (modelNode instanceof UserEntry) {
				UserEntry subNode = (UserEntry) modelNode;
				subsequence.add(subNode);
			}
		}
		return subsequence;
	}

	private String dataType;
	private boolean hasDefault = false;
	private Object value;
	private boolean useDefault;
	private boolean isValueSeted;

	UserEntry(Node node, int svrlIdx, int index) throws DOMException,
			URISyntaxException, XPathExpressionException {
		super(node, svrlIdx);
		this.setIndex(index);
		XPathReader xpathreader = new XPathReader();
		Node param = xpathreader.getNode("sqf:param", node);
		this.setId(SVRLReport.XPR.getAttributValue(param, "param-id"));
		this.dataType = SVRLReport.XPR.getAttributValue(param, "as", "",
				"xs:string");
		NodeList paramChilds = xpathreader.getNodeSet(".//node()", param);
			this.hasDefault = paramChilds.getLength() > 0;

		// S E T N A M E
		NodeList texte = xpathreader.getNodeSet("sqf:description/es:text",
				node);
		String description = "";
		for (int i = 0; i < texte.getLength(); i++) {
			description += texte.item(i).getTextContent();
			if (i + 1 < texte.getLength())
				description += " ";
		}
		this.setName(description);

	}

	@Override
	public Object getValue() {
		return this.value;
	}

	@Override
	public void setValue(Object value) {
		this.value = value;
		this.isValueSeted = true;
	}

	@Override
	public void setValue(Object value, boolean useDefault) {
		this.value = value;
		this.useDefault = useDefault;
		this.isValueSeted = true;
	}

	@Override
	public boolean hasDefault() {
		return this.hasDefault;
	}

	@Override
	public boolean usingDefault() {
		return this.useDefault;
	}

	@Override
	public boolean isValueValid() {
		return this.isValueSeted;
	}

	@Override
	public String getDataType() {
		return this.dataType;
	}

}
