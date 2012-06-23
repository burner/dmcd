module symtabentry;

import hurt.string.stringstore;
import hurt.container.store;

import symtab;
import location;

struct SymTabItem {
	private hurt.string.stringstore.strptr!dchar identifier;
	private hurt.string.stringstore.strptr!dchar typ;
	private strPtr childs;
	private uint attributes;
	//private bool pseudoScope;
	private Location loc;
	private SymTab symtab;

	this(SymTab symtab, strptr!dchar identifier, strptr!dchar typ, Location loc,
			uint attributes) {
		this.symtab = symtab;
		this.identifier = identifier;
		this.typ = typ;
		this.attributes = attributes;
		this.loc = loc;
	}

	this(SymTab symtab, strptr!dchar identifier, strptr!dchar typ, 
			Location loc) {
		this(symtab, identifier, typ, loc, 0);
	}

	public void setSymTab(SymTab symtab) {
		this.symtab = symtab;
	}

	/*public bool isPseudoScope() const {
		return this.pseudoScope;
	}*/

	public strPtr getChildPtr() {
		return this.childs;
	}

	public void setChildPtr(strPtr ptr) {
		this.childs = ptr;
	}

	public bool opEquals(const ref SymTabItem other) const {
		return this.loc == other.loc && this.identifier == other.identifier;
	}

	public bool opEquals(const SymTabItem other) const {
		return this.loc == other.loc && this.identifier == other.identifier;
	}
}
