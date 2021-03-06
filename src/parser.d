module parser;

import std.concurrency;
import core.thread;

import hurt.algo.binaryrangesearch;
import hurt.container.deque;
import hurt.io.stdio;
import hurt.util.pair;
import hurt.util.slog;
import hurt.util.util;
import hurt.math.mathutil;
import hurt.string.formatter;
import hurt.string.stringstore;
import hurt.string.stringbuffer;

import ast;
import lexer;
import lextable;
import location;
import parsetable;
import token;
import parserutil;
import symtab;

class Parse {
	private int id;
	private long tokenBufIdx;
	private Parser parser;
	private Deque!(int) parseStack;
	private Deque!(Token) tokenStack;
	private AST ast;
	private Token input;
	private SymTab symTab;

	private bool dontPopToken;

	// trace
	private Deque!(Pair!(TableItem,int)) trace;

	this(Parser parser, int id) {
		this.parser = parser;
		this.id = id;
		this.parseStack = new Deque!(int)(128);
		this.tokenStack = new Deque!(Token)(128);
		// we start at state (zero null none 0)
		this.parseStack.pushBack(0);

		this.ast = new AST();
		this.tokenBufIdx = 0;
		this.input = this.getToken();

		// trace
		this.trace = new Deque!(Pair!(TableItem,int))(128);
		this.dontPopToken = false;
		this.symTab = new SymTab();
	}

	this(Parser parser, Parse toCopy, int id) {
		this.parser = parser;
		if(toCopy.parseStack !is null) {
			this.parseStack = new Deque!(int)(toCopy.parseStack);
		} else {
			warn("parseStack was null");
		}
		if(toCopy.tokenStack !is null) {
			this.tokenStack = new Deque!(Token)(toCopy.tokenStack);
		} else {
			warn("tokenStack was null");
		}
		this.tokenBufIdx = toCopy.tokenBufIdx;
		if(toCopy.ast !is null) {
			this.ast = new AST(toCopy.ast);
		} else {
			warn("ast was null");
		}
		if(this.ast !is null && toCopy.ast !is null) {
			assert(this.ast == toCopy.ast);
		}

		this.tokenBufIdx = toCopy.tokenBufIdx;
		this.input = toCopy.input;
		this.id = id;

		// trace
		if(toCopy.trace !is null) {
			this.trace = new Deque!(Pair!(TableItem,int))(toCopy.trace);
		}
		this.dontPopToken = toCopy.dontPopToken;
		if(toCopy.symTab !is null) {
			this.symTab = new SymTab(toCopy.symTab);
			assert(this.symTab == toCopy.symTab);
		}
	}

	public TableItem getLastAction() const {
		return this.trace.back().first;
	}

	package int getId() const {
		return this.id;
	}

	public bool copyEqualButDistinged(Parse p) @trusted {
		if(p is this) {
			log();
			return false;
		}
		
		if(this.ast != p.ast) {
			log();
			return false;
		}

		if(this.parseStack is p.parseStack || this.parseStack != p.parseStack) {
			log();
			return false;
		}

		if(this.tokenStack is p.tokenStack || this.tokenStack != p.tokenStack) {
			log();
			return false;
		}

		return this.input == p.input;
	}

	public override bool opEquals(Object o) @trusted {
		Parse p = cast(Parse)o;

		if(this.tokenBufIdx != p.tokenBufIdx) {
			return false;
		}

		// no need to compare every element if the size is not equal
		if(this.parseStack.getSize() != p.parseStack.getSize()) {
			return false;
		}

		// compare the parseStack from the back to the front
		// because the difference should be at the back
		for(auto it = this.parseStack.cEnd(), jt = p.parseStack.cEnd(); 
				it.isValid() && jt.isValid(); it--, jt--) {
			if(*it != *jt) {
				return false;
			}
		}

		return true;
	}

	package const(Token) getCurrentInput() const {
		return this.input;
	}

	package int getTos() const {
		//return this.parseStack[this.parseStack.getSize()-1];
		return this.parseStack.back();
	}

	package AST getAst() {
		return this.ast;
	}

	private Token getToken() {
		return this.parser.increToNextToken(this.tokenBufIdx++);
	}

	private Token buildTreeWithLoc(immutable int retType, immutable(int[]) 
			tokens, size_t rule, Location loc) {

		assert(tokens !is null);
		assert(tokens.length > 0);

		// insert all the token that are not yet placed in the ast
		foreach(idx, it; tokens) {
			 if(!this.tokenStack[it].isPlacedInAst()) {
				size_t npos = this.ast.insert(
					this.tokenStack[it], // the token
					rules[rule][negIdx(rules[rule], it)]);
				this.tokenStack[it] = Token(this.tokenStack[it], npos);
				assert(this.tokenStack[it].getTreeIdx() == npos);
			 }
		}

		Token ret = Token(loc, retType);
		size_t pos = this.ast.insert(ret, retType);

		foreach(idx, it; tokens) {
			Token tmp = this.tokenStack[it];
			this.ast.append(tmp.getTreeIdx());
		}
		return Token(ret, pos);
	}

	private Token buildTree(immutable int retType, immutable(int[]) tokens, 
			size_t rule, immutable int startPosIdx = 0) {
		assert(tokens !is null);
		assert(tokens.length > 0);

		// insert all the token that are not yet placed in the ast
		foreach(idx, it; tokens) {
			if(idx == startPosIdx) { // ignore the head of the tree
				continue;
			 }
			 if(!this.tokenStack[it].isPlacedInAst()) {
				size_t npos = this.ast.insert(
					this.tokenStack[it], // the token
					rules[rule][negIdx(rules[rule], it)]);
				this.tokenStack[it] = Token(this.tokenStack[it], npos);
			 }
		}

		size_t pos = this.ast.insert(this.tokenStack[tokens[startPosIdx]],
			retType);

		foreach(idx, it; tokens) {
			if(idx == startPosIdx) { // ignore the head of the tree
				continue;
			}

			Token tmp = this.tokenStack[it];
			this.ast.append(tmp.getTreeIdx());
		}
		/*Token ret = Token(this.tokenStack[tokens[startPosIdx]].getLoc(), 
			retType, pos);*/
		Token tmp = this.tokenStack[tokens[startPosIdx]];
		Token ret = Token(tmp, pos);
		return ret;
	}

	public immutable(TableItem[]) getAction() const {
		immutable(Pair!(int,immutable(immutable(TableItem)[]))) retError = 
			Pair!(int,immutable(immutable(TableItem)[]))(int.min, 
			[TableItem(TableType.Error, 0)]);

		immutable(Pair!(int,immutable(immutable(TableItem)[]))) toSearch = 
			Pair!(int,immutable(immutable(TableItem)[]))(
			this.input.getTyp(), [TableItem(false)]);

		//log("%s", this.input.toString());

		immutable(immutable(Pair!(int,immutable(TableItem[])))[]) row
			= parseTable[this.parseStack.back()];

		bool found;
		size_t foundIdx;

		auto ret = binarySearch!(TitP)
			(row, toSearch, retError, row.length, found, foundIdx,
			function(immutable(Pair!(int,immutable(TableItem[]))) a, 
					immutable(Pair!(int,immutable(TableItem[]))) b) {
				return a.first > b.first;
			}, 
			function(immutable(Pair!(int,immutable(TableItem[]))) a, 
					immutable(Pair!(int,immutable(TableItem[]))) b) {
				return a.first == b.first; });

		return ret.second;
	}

	private short getGoto(const int input) const {
		immutable(Pair!(int,immutable(immutable(TableItem)[]))) retError = 
			Pair!(int,immutable(immutable(TableItem)[]))(int.min, 
			[TableItem(TableType.Error, 0)]);

		immutable(Pair!(int,immutable(immutable(TableItem)[]))) toSearch = 
			Pair!(int,immutable(immutable(TableItem)[]))(
			input, [TableItem(false)]);

		auto row = gotoTable[this.parseStack.back()];
		bool found;
		size_t foundIdx;

		auto ret = binarySearch!((TitP))
			(row, toSearch, retError, row.length, found, foundIdx,
			function(immutable(Pair!(int,immutable(TableItem[]))) a, 
					immutable(Pair!(int,immutable(TableItem[]))) b) {
				return a.first > b.first;
			}, 
			function(immutable(Pair!(int,immutable(TableItem[]))) a, 
					immutable(Pair!(int,immutable(TableItem[]))) b) {
				return a.first == b.first; });


		assert(ret.second.length == 1);
		return ret.second[0].getNumber();
	}

	private void runAction(short actionNum) {
		Token ret;
		//log("actionNum %d", actionNum);
		switch(actionNum) {
			mixin(actionString);
			default:
				assert(false, format("no action for %d defined", actionNum));
		}
		//log("%d", this.id);
		//log("%s", ret.toString());
		if(!this.dontPopToken) {
			this.tokenStack.popBack(rules[actionNum].length-1);
			this.tokenStack.pushBack(ret);
		}

		this.dontPopToken = false;
		//this.printTokenStack();
		//this.printStack();
		//log("%s", this.ast.toString());

	}

	private void printStack() const {
		printf("parse stack %d: ", this.id);
		foreach(it; this.parseStack) {
			printf("%d ", it);
		}
		println();
	}

	private string stackToString() const {
		auto ret = new StringBuffer!(char)("parse stack");
		ret.pushBack(" id %d:", this.id);
		foreach(it; this.parseStack) {
			ret.pushBack("%d ", it);
		}
		ret.pushBack('\n');
		return ret.getString();
	}


	private void printTokenStack() const {
		printf("token stack %d: ", this.id);
		foreach(it; this.tokenStack) {
			printf("%s:%d ", it.toStringShort(), it.getTreeIdx());
		}
		println();
	}

	private string traceToString() const {
		auto ret = new StringBuffer!(char)(128);
		ret.pushBack("Parse %d Trace:", this.id);
		foreach_reverse(const size_t idx, const Pair!(TableItem,int) it; 
				this.trace) {
			ret.pushBack("%d:%s\n", it.second, tableitemToString(it.first));
			if(idx == 15) {
				break;
			}
		}
		return ret.getString();
	}

	private string tokenStackToString() const {
		auto ret = new StringBuffer!(char)("token stack ");
		ret.pushBack("%d:", this.id);
		auto cnt = 0;
		foreach_reverse(it; this.tokenStack) {
			ret.pushBack("%s ", it.toStringShort());
		}
		ret.pushBack('\n');
		return ret.getString();
	}

	private string reportError(const Token input) const {
		StringBuffer!(char) ret = new StringBuffer!(char)(1023);
		ret.pushBack(
			"%?1!1s in state %?1!1d on input %?1!1s this is parse %d\n", 
			"ERROR", this.parseStack.back(), input.toString(), this.id);
		ret.pushBack(this.stackToString());
		ret.pushBack(this.tokenStackToString());
		ret.pushBack(this.traceToString());
		return ret.getString();
	}

	public Pair!(int,string) step(immutable(TableItem[]) actionTable, 
			size_t actIdx) {
		TableItem action = actionTable[actIdx];
		//Token input = this.getToken();
		//this.tokenStack.pushBack(input);
		//log("%s", input.toString());
		
		//action = this.getAction(input)[actIdx]; 
		//log("%s", action.toString());
		//this.printStack();
		if(action.getTyp() == TableType.Accept) {
			//log("%s %s", action.toString(), input.toString());
			this.trace.pushBack(Pair!(TableItem,int)(action,
				action.getNumber()));
			this.parseStack.popBack(rules[action.getNumber()].length-1);
			this.runAction(action.getNumber());
			return Pair!(int,string)(1,"");
		} else if(action.getTyp() == TableType.Error) {
			//log();
			return Pair!(int,string)(-1,this.reportError(input));
		} else if(action.getTyp() == TableType.Shift) {
			//log("%s", input.toString());
			//log();
			this.parseStack.pushBack(action.getNumber());

			// trace
			this.trace.pushBack(Pair!(TableItem,int)(action,
				action.getNumber()));

			this.tokenStack.pushBack(input);
			input = this.getToken();
		} else if(action.getTyp() == TableType.Reduce) {
			/*log("%d %d %d", this.id, rules[action.getNumber()].length-1, 
				this.parseStack.getSize());*/
			// do action
			// pop RHS of Production
			//this.parseStack.popBack(rules[action.getNumber()].length-1);
			/*for(int i = 0; i < rules[action.getNumber()].length-1; i++) {
				printf("%s ", this.tokenStack[-(i+1)].toStringShort());
			}
			println();
			log();*/
			for(int i = 0; i < rules[action.getNumber()].length-1; i++) {
				long len = rules[action.getNumber()].length-1;
				/*
				log("len %d tokenStack %d parseStack %d access %d\nrule len %d",
					len, this.tokenStack.getSize(), this.parseStack.getSize(),
					-(i+1), rules[action.getNumber()].length);*/
				if(this.tokenStack[-(i+1)].getTyp() == 
						rules[action.getNumber()][$ - 1 - i]) {
					//log();
					this.parseStack.popBack();
				} else {
					log();
					return Pair!(int,string)(-1, this.reportError(input) ~
						format("while poping right hand side of rule %d (%s)"
						~ " we found %s instead of %s", action.getNumber(),
						prodToString(action.getNumber()).getString(),
						idToString(this.tokenStack[-(len+i+1)].getTyp()), 
						idToString(rules[action.getNumber()][i+1])));
				}
			}

			this.parseStack.pushBack(
				this.getGoto(rules[action.getNumber()][0]));

			// trace
			//this.trace.pushBack(action.getNumber());
			this.trace.pushBack(Pair!(TableItem,int)(action,
				action.getNumber()));

			// tmp token stack stuff
			this.runAction(action.getNumber());
		}
		//printfln("id %d ast %s", this.id, this.ast.toStringGraph());
		return Pair!(int,string)(0,"");
	}

	//void openScope(strptr!dchar identifier, strptr!dchar typ, Location loc,
			//uint attributes = 0) {
	void openScope(long identIdx, long typIdx, long attribIdx = 0) {
		Location loc;
		strptr!dchar identifier;
		strptr!dchar typ;
		uint attributes;
		this.symTab.openScope(identifier, typ, loc, attributes);
	}

	void closeScope() {
		this.symTab.closeScope();
	}

	void append(strptr!dchar identifier, strptr!dchar typ, Location loc,
			uint attributes = 0) {
		this.symTab.append(identifier, typ, loc, attributes);
	}
}

class Parser : Thread {
	private Lexer lexer;
	private Deque!(Token) tokenBuffer;
	private Deque!(Token) tokenStore;
	private Deque!(Parse) parses;
	private Deque!(Parse) newParses;
	private Deque!(Parse) acceptingParses;
	private Deque!(int) toRemove;
	private Deque!(Pair!(int,string)) parseError;
	private int nextId;
	private bool lastTokenFound;

	private Tid parent;

	public this(Lexer lexer, Tid parent) {
		super(&run);
		this.parent = parent;
		this.lexer = lexer;	
		this.tokenBuffer = new Deque!(Token)(64);
		this.tokenStore = new Deque!(Token);
		assert(this.tokenStore.isEmpty());
		assert(this.tokenStore.getSize() == 0, 
			format("%d", this.tokenStore.getSize()));
		this.parses = new Deque!(Parse)(16);
		this.nextId = 0;
		this.parses.pushBack(new Parse(this,this.nextId++));
		this.newParses = new Deque!(Parse)(16);
		this.acceptingParses = new Deque!(Parse)(16);
		this.toRemove = new Deque!(int)(16);
		this.parseError = new Deque!(Pair!(int,string))(16);
		this.lastTokenFound = false;
	} 

	public AST getAst() {
		assert(!this.acceptingParses.isEmpty());
		return this.acceptingParses.front().getAst();
	}

	/** do not call this direct unless you want whitespace token
	 */
	private Token getNextToken() { 
		if(this.tokenBuffer.isEmpty()) {
			this.lexer.getToken(this.tokenBuffer);
		} 
		if(this.tokenBuffer.isEmpty()) {
			return Token(termdollar);
		} else {
			return this.tokenBuffer.popFront();
		}
	}

	private Token getToken() {
		Token t = this.getNextToken();
		if(t.getTyp() == termdollar) {
			this.lastTokenFound = true;
		}
		while(t.getTyp() == -99) {
			if(t.getTyp() == termdollar) {
				this.lastTokenFound = true;
			}
			t = this.getNextToken();
		}
		//log("%s", t.toString());
		return t;
	}

	package Token increToNextToken(long idx) {
		//log("%d %d", idx, this.tokenStore.getSize());
		if(idx + 1 >= this.tokenStore.getSize()) {
			//log("lastTokenFound %b", this.lastTokenFound);
			if(this.lastTokenFound) {
				return Token(termdollar);
			}
			this.tokenStore.pushBack(this.getToken());
		}
		//log("%u", this.tokenStore.getSize());

		return this.tokenStore[idx++];
	}

	private int merge(Parse a, Parse b) {
		// AndAnd := OrExp | CmpExp
		log("a id %d last action %s", a.getId(), tableitemToString(a.getLastAction()));
		log("b id %d last action %s", b.getId(), tableitemToString(b.getLastAction()));
		return b.getId();
	}

	private void mergeRun(Deque!(Parse) parse) {
		// early exit if only one parse is left
		if(parse.getSize() <= 1) {
			return;
		}
		// remove all accepting parses or merged away parses
		// call merge function for all parse that are equal
		for(size_t i = 0; i < parse.getSize() - 1; i++) {
			if(this.toRemove.contains(parse[i].getId())) {
				continue;
			}
			for(size_t j = i+1; j < parse.getSize(); j++) {
				if(this.toRemove.contains(parse[j].getId())) {
					continue;
				}

				// for every tow parse that are equal call the merge 
				// function
				if(parse[i] == parse[j]) {
					this.toRemove.pushBack(
						this.merge(parse[i], parse[j]) 
					);
				}
			}
		}
	}

	public void parse() {
		while(!this.parses.isEmpty()) {
			// for every parse
			for(size_t i = 0; i < this.parses.getSize(); i++) {
				// get all actions
				immutable(TableItem[]) actions = this.parses[i].getAction();
				// if there are more than one action we found a conflict
				if(actions.length > 1) {
					log("fork at id %d, tos %d, input %s, number of actions %d",
						this.parses[i].getId(), this.parses[i].getTos(),
						this.parses[i].getCurrentInput().toString(), 
						actions.length);
					
					for(size_t j = 1; j < actions.length; j++) {
						Parse tmp = new Parse(this, this.parses[i], 
							this.nextId++);
						assert(tmp.copyEqualButDistinged(this.parses[i]));
						auto rslt = tmp.step(actions, j);
						if(rslt.first == 1) {
							this.acceptingParses.pushBack(this.parses[i]);
							this.toRemove.pushBack(this.parses[i].getId);
						} else if(rslt.first == -1) {
							this.toRemove.pushBack(this.parses[i].getId);
							this.parseError.pushBack(rslt);
						} else {
							this.newParses.pushBack(tmp);
						}
					}
				}

				// after all one action is left
				auto rslt = this.parses[i].step(actions, 0);
				if(rslt.first == 1) {
					this.acceptingParses.pushBack(this.parses[i]);
					this.toRemove.pushBack(this.parses[i].getId);
				} else if(rslt.first == -1) {
					this.toRemove.pushBack(this.parses[i].getId);
					this.parseError.pushBack(rslt);
				} 
			}
			// copy all new parses
			while(!this.newParses.isEmpty()) {
				this.parses.pushBack(this.newParses.popBack());
			}

			this.mergeRun(this.parses);

			this.parses.removeFalse(delegate(Parse a) {
				return this.toRemove.containsNot(a.getId()); });

			//log("%d", this.toRemove.getSize());
			this.toRemove.clean();
			if(this.parses.isEmpty() && this.acceptingParses.isEmpty()) {
				foreach(it; this.parseError) {
					printfln("%s", it.second);
				}
			}
			this.parseError.clean();
			//log("%d", this.toRemove.getSize());
		}

		// this is necessary because their might be more than one accepting 
		// parse
		this.mergeRun(this.acceptingParses);
		//return !this.acceptingParses.isEmpty();
		send(this.parent, !this.acceptingParses.isEmpty());
	}

	void run() {
		this.parse();
	}
}
