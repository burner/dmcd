module symtab;

import hurt.container.deque;
import hurt.container.map;
import hurt.container.store;
import hurt.container.stack;
import hurt.string.stringstore;

import symtabentry;
import location;

class SymTab {
	Deque!(SymTabItem) symbols;
	Store childIdStore;
	Stack!(size_t) symbolStack;

	this() {
		this.symbols = new Deque!(SymTabItem)();
		this.childIdStore = new Store();
	}
	
	this(SymTab toCopy) {
		this.symbols = new Deque!(SymTabItem)(toCopy.symbols);
		this.childIdStore = toCopy.childIdStore;
		this.symbolStack = new Stack!(size_t)(toCopy.symbolStack);
	}

	/** Assing idx to the last pointer of the cp pointer.
	 */
	private static void appendIdxAtEnd(strPtr cp, size_t idx) {
		size_t* p = cast(size_t*)cp.getPointer;
		size_t cnt = cp.getSize() / size_t.sizeof;
		cnt--;
		p += cnt;

		*p = idx;
	}

	/*  append a child to the current top of the symbolStack.
		this is done for example when adding a variable to a function scope.
	*/
	void append(strptr!dchar identifier, strptr!dchar typ, Location loc,
			uint attributes = 0) {
		SymTabItem s = SymTabItem(this, identifier, typ, loc, attributes);
		this.symbols.pushBack(s);

		strPtr childsOfCurrentScope = this.symbols[this.symbolStack.top()].
			getChildPtr();
		childsOfCurrentScope = this.childIdStore.realloc(childsOfCurrentScope,
			childsOfCurrentScope.getSize()+ size_t.sizeof);
		SymTab.appendIdxAtEnd(childsOfCurrentScope, this.symbols.getSize()-1);
	}

	void openScope(strptr!dchar identifier, strptr!dchar typ, Location loc,
			uint attributes = 0) {
		SymTabItem item = SymTabItem(this, identifier, typ, loc, attributes);
		this.symbols.pushBack(item);
		this.symbolStack.push(this.symbols.getSize()-1);
	}

	void closeScope() {
		assert(!this.symbolStack.isEmpty());
		this.symbolStack.pop();
	}

	public override bool opEquals(Object o) {
		SymTab s = cast(SymTab)o;
		if(this.symbols != s.symbols) {
			return false;
		}

		if(this.symbolStack != s.symbolStack) {
			return false;
		}

		if(this.childIdStore !is s.childIdStore) {
			return false;
		}

		return true;
	}
}
