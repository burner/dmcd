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

	/*  append a child to the current top of the symbolStack.
		this is done for example when adding a variable to a function scope.
	*/
	
	void append(strptr!dchar identifier, strptr!dchar typ, Location loc,
			uint attributes = 0) {

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
}
