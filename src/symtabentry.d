module symtabentry;

import hurt.string.stringstore;
import hurt.container.map;
import hurt.util.pair;

struct SymTabEntry {
	private strptr!dchar identifier;
	private strptr!dchar typ;
	private uint attributes;
	private Pair!(size_t,size_t) childs;

	this(strptr!dchar identifier, strptr!dchar typ, uint attributes, 
			size_t childIdx) {
		this.identifier = identifier;
		this.typ = typ;
		this.attributes = attributes;
		this.childs = Pair!(size_t,size_t)(childIdx,0);
	}

	public void appendChild() {
		this.childs.second++;
	}
}
