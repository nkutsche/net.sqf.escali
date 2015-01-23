package net.sqf.escali.control.report;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Iterator;

import javax.xml.xpath.XPathExpressionException;

import net.sqf.escali.control.SVRLReport;
import net.sqf.escali.control.types.TypeConverter;
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
//	private boolean hasDefault = false;
	private final Object defaultValue;
	private Object value;
	private boolean useDefault;
	private final TypeConverter converter;
	
	private boolean isValueValid = true;
	

	UserEntry(Node node, int svrlIdx, int index) throws DOMException,
			URISyntaxException, XPathExpressionException {
		super(node, svrlIdx);
		this.setIndex(index);
		XPathReader xpathreader = new XPathReader();
		Node param = xpathreader.getNode("sqf:param", node);
		this.setId(SVRLReport.XPR.getAttributValue(param, "param-id"));
		this.dataType = SVRLReport.XPR.getAttributValue(param, "as", "",
				"xs:string");
		
		String required = SVRLReport.XPR.getAttributValue(param, "required", "", "no");
		if(required.equals("yes")){
			isValueValid = false;
		}
		
		this.converter = new TypeConverter(this.dataType);
		
		NodeList paramChilds = xpathreader.getNodeSet("./node()", param);
		
		if(paramChilds.getLength() > 0){
			String stringValue = "";
			for (int i = 0; i < paramChilds.getLength(); i++) {
				Node textNode = paramChilds.item(i);
				stringValue += textNode.getNodeValue();
			}
			defaultValue = converter.convertValue(stringValue);
			setValue(defaultValue);
//			this.hasDefault = true;
			this.isValueValid = true;
		} else {
			defaultValue = null;
		}
		

		// S E T N A M E
		Node nameNode = xpathreader.getNode("sqf:description/sqf:title", node);
//		NodeList texte = xpathreader.getNodeSet("sqf:description/es:text",
//				node);
//		String description = "";
//		for (int i = 0; i < texte.getLength(); i++) {
//			description += texte.item(i).getTextContent();
//			if (i + 1 < texte.getLength())
//				description += " ";
//		}
		this.setName(nameNode.getTextContent());
	}
	
	

	@Override
	public Object getValue() {
		return this.value;
	}

	@Override
	public void setValue(Object value) {
		if(value == null){
			useDefaultIfAvailable();
		} else {
			this.value = value;
			this.isValueValid = true;
		}
	}

//	@Override
//	public void setValue(Object value, boolean useDefault) {
//		this.value = value;
//		this.useDefault = useDefault;
//		this.isValueValid = true;
//	}
	@Override
	public void useDefaultIfAvailable(){
		if(hasDefault()){
			this.value = this.defaultValue;
			this.isValueValid = true;
		} else {
			this.value = null;
			this.isValueValid = false;
		}
	}

	@Override
	public boolean hasDefault() {
		return defaultValue != null;
	}

	@Override
	public boolean usingDefault() {
		return this.useDefault;
	}

	@Override
	public boolean isValueValid() {
		return this.isValueValid;
	}
	
	@Override
	public boolean isValueSet() {
		return this.isValueValid && !usingDefault();
	}

	@Override
	public String getDataType() {
		return this.dataType;
	}
	
	@Override
	public TypeConverter getTypeConverter(){
		return this.converter;
	}

}
