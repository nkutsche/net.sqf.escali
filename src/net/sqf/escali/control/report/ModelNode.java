package net.sqf.escali.control.report;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;

import net.sqf.escali.control.SVRLReport;
import net.sqf.xmlUtils.xpath.ProcessNamespaces;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;

abstract class ModelNode implements _ModelNode {
	private final URI icon;
	private final String baseUri;
	private boolean hasIcon = false;
	private final URI link;
	private boolean hasLink = false;
//	private final ArrayList<_ModelNode> children = new ArrayList<_ModelNode>();
	private final LinkedHashMap<String, _ModelNode> childrenByID = new LinkedHashMap<String, _ModelNode>();
	private _ModelNode parent;
	private boolean hasParent = false;
	private String id;
	private int index;
	private final int svrlIdx;
	private String name;

	ModelNode(Node node, int svrlIdx) throws DOMException, URISyntaxException {
		this.svrlIdx = svrlIdx;
		this.icon = new URI(SVRLReport.XPR.getAttributValue(node, "icon",
				ProcessNamespaces.ES_NS));
		if (!icon.equals(new URI("")))
			this.hasIcon = true;
		this.link = new URI(SVRLReport.XPR.getAttributValue(node, "link",
				ProcessNamespaces.ES_NS));
		if (!link.equals(new URI("")))
			this.hasLink = true;
		
		this.baseUri = node.getBaseURI();

	}

	public ModelNode(int svrlIdx, String baseUri) {
		this.svrlIdx = svrlIdx;
		this.icon = null;
		this.hasIcon = false;
		this.link = null;
		this.hasLink = false;
		this.baseUri = baseUri;
	}

	// ID
	@Override
	public String getId() {
		return this.id;
	}

	@Override
	public void setId(String id) {
		this.id = id;
	}

	@Override
	public _ModelNode getParent() {
		return this.parent;
	}

	// P A R E N T
	@Override
	public void setParent(_ModelNode parent) {
		this.hasParent = true;
		this.parent = parent;
	}

	@Override
	public boolean hasParent() {
		// TODO Auto-generated method stub
		return this.hasParent;
	}

	// C H I L D R E N
	@Override
	public ArrayList<_ModelNode> getChildren() {
		ArrayList<_ModelNode> nodes = new ArrayList<_ModelNode>(this.childrenByID.values());
		return nodes;
	}
	@Override
	public ArrayList<_ModelNode> getChildById(String[] ids){
		ArrayList<_ModelNode> children = new ArrayList<_ModelNode>();
		for (String id : ids) {
			_ModelNode child = this.getChildById(id);
			if(child != null){
				children.add(child);
			}
		}
		return children;
	}
	@Override
	public _ModelNode getChildById(String id){
		if(this.childrenByID.containsKey(id)){
			return this.childrenByID.get(id);
		} else {
			for (_ModelNode child : this.getChildren()) {
				_ModelNode selChild = child.getChildById(id);
				if(selChild != null){
					return selChild;
				}
			}
			return null;
		}
	}
	

	@Override
	public void addChild(_ModelNode child) {
		child.setParent(this);
		this.childrenByID.put(child.getId(), child);
	}

	@Override
	public void addChild(ArrayList<_ModelNode> children) {
		for (Iterator<_ModelNode> iterator = children.iterator(); iterator
				.hasNext();) {
			_ModelNode child = iterator.next();
			addChild(child);
		}
	}

	@Override
	public int getChildCount() {
		return this.childrenByID.size();
	}

	// N A M E
	@Override
	public void setName(String name) {
		this.name = name;
	};

	@Override
	public String getName() {
		return this.name;
	}

	// I N D E X
	@Override
	public int getIndex() {
		// TODO Auto-generated method stub
		return this.index;
	}

	public void setIndex(int index) {
		this.index = index;
	};

	@Override
	public int getSvrlIndex() {
		return this.svrlIdx;
	}

	// I C O N
	@Override
	public URI getIcon() {
		// TODO Auto-generated method stub
		return this.icon;
	}

	@Override
	public boolean hasIcon() {
		// TODO Auto-generated method stub
		return this.hasIcon;
	}

	// L I N K
	@Override
	public URI getLink() {
		// TODO Auto-generated method stub
		return this.link;
	}

	@Override
	public boolean hasLink() {
		// TODO Auto-generated method stub
		return this.hasLink;
	}

	public String toString() {
		return getName();
	}
	
	@Override
	public String getBaseUri() {
		// TODO Auto-generated method stub
		return this.baseUri;
	}
}
