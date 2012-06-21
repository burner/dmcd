module token;

import hurt.string.stringbuffer;
import hurt.string.formatter;
import hurt.string.stringstore;
import hurt.util.slog;
import hurt.conv.conv;

import lextable;
import location;
import parsetable;

struct Token {
	private Location loc;
	// if this is -3 treeIdx gives you the index of the ast node
	private int typ; 
	private strptr!dchar value;
	private long treeIdx; // the index of the ast node in the ast array
	private bool treeIdxPlaced;

	this(int typ) {
		this.typ = typ;
		this.treeIdxPlaced = false;
		this.treeIdx = -1;
	}

	this(int typ, strptr!dchar value) {
		this(typ);
		this.value = value;
	}

	this(Location loc, int typ, 
			strptr!dchar value = strptr!(dchar)(null, 0, 0 ,0)) {
		this(typ);
		this.loc = loc;
		this.value = value;
	}

	this(Location loc, int typ, long treeIdx) {
		this.loc = loc;
		this.typ = typ;
		this.treeIdx = treeIdx;
		this.treeIdxPlaced = true;
	}

	this(Token toCopy, long treeIdx) {
		this(toCopy.loc, toCopy.typ, treeIdx);
		this.value = toCopy.value;
	}

	public bool isPlacedInAst() const @trusted {
		return this.treeIdxPlaced;
	}

	string toString() const {
		scope StringBuffer!(char) ret = new StringBuffer!(char)(128);	

		// the location
		ret.pushBack("%s:%d.%d ", loc.getFile(), loc.getRow(), 
			loc.getColumn());
		
		// the payload
		ret.pushBack("%s %s", idToString(typ), 
			conv!(dstring,string)(value.toString()));

		ret.pushBack(" %b:%d", this.treeIdxPlaced, this.treeIdx);

		return ret.getString();
	}

	string toStringShort() const {
		if(this.treeIdxPlaced) {
			if(value.toString() == "") {
				return format("[%s ti %u]", idToString(typ), this.treeIdx);
			} else {
				return format("[%s v %s ti %u]", idToString(typ), 
					conv!(dstring,string)(value.toString()), this.treeIdx);
			}
		} else {
			if(value.toString() == "") {
				return format("[%s]", idToString(typ));
			} else {
				return format("[%s v %s]", idToString(typ), 
					conv!(dstring,string)(value.toString()));
			}
		}
	}

	public int getTyp() const {
		return this.typ;
	}

	public const(dstring) getValue() const {
		return this.value.toString();
	}

	public Location getLoc() const {
		return this.loc;
	}

	public long getTreeIdx() const {
		return this.treeIdx;
	}
}
