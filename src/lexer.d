module lexer;

import core.sync.semaphore;
import core.sync.mutex;
import core.thread;

import std.concurrency;

import hurt.algo.binaryrangesearch;
import hurt.container.map;
import hurt.container.stack;
import hurt.container.deque;
import hurt.conv.conv;
import hurt.io.file;
import hurt.io.stdio;
import hurt.io.stream;
import hurt.string.formatter;
import hurt.string.stringbuffer;
import hurt.string.stringstore;
import hurt.string.utf;
import hurt.util.slog;
import hurt.util.pair;
import hurt.conv.convutil;

import lextable;
import location;
import parsetable;
import token;
import exceptions;

class Lexer : Thread {
	private string filename;
	private hurt.io.stream.BufferedFile file;

	private size_t lineNumber;
	private size_t charIdx;
	private dchar[] currentLine;
	private StringBuffer!(dchar) lexText;
	private Stack!(dchar) inputChar;
	private immutable dchar eol = '\n';
	private immutable dchar eof = '\0';

	// to exchange stuff
	__gshared private Deque!(Token) deque;
	__gshared Mutex mutex;
	__gshared Semaphore empty;
	__gshared uint count;
	__gshared bool isLocked;
	__gshared StringStore!dchar stringStore;
	private __gshared bool lockDisabled = false;

	private Location loc;

	// true means single run, false means step be step
	private bool kind;

	private Tid parent;

	this(string filename, bool kind, uint count, Tid parent) {
		super(&run);
		this.parent = parent;
		this.filename = filename;
		this.lineNumber = 0;
		this.inputChar = new Stack!(dchar)();

		// the exchange stuff
		this.deque = new Deque!(Token)(128);
		this.mutex = new Mutex();
		this.empty = new Semaphore(0);
		this.count = count;
		this.isLocked = false;
		this.stringStore = new StringStore!dchar();

		if(!exists(this.filename)) {
			throw new Exception(__FILE__ ~ ":" ~ conv!(int,string)(__LINE__) ~
				this.filename ~ " does not exists");
		}

		this.file = null;
		this.file = new hurt.io.stream.BufferedFile(this.filename);
		this.lexText = new StringBuffer!(dchar)(128);
		this.getNextLine();

		this.kind = kind;
		/*if(this.kind) {
			this.start();
		}*/
	}

	~this() {
	}

	public void printFile() {
		foreach(char[] it; this.file) {
			foreach(char jt; it)
				print(jt);
			println();
		}
	}

	public Deque!(Token) getTokenDeque() {
		return this.deque;
	}

	private dstring getCurrentLex() const {
		return this.lexText.getString();
	}

	private size_t getCurrentLineCount() const {
		return this.lineNumber;
	}

	private size_t getCurrentIndexInLine() const {
		return this.charIdx;
	}

	public string getFilename() const {
		return this.filename;
	}

	private bool isEOF() {
		return this.file.eof();	
	}

	private stateType getNextState(dchar inputChar, stateType currentState) 
			const {
		size_t column = binarySearchRange!(dchar,size_t)(inputRange, inputChar,
			-2);
		size_t row = stateMapping[conv!(stateType,size_t)(currentState)];
		if(column == -2) {
			return -1;
		}
		return lextable.table[row][column];
	}

	public bool isEmpty() {
		return this.isEOF() && (this.currentLine is null || 
			this.charIdx > this.currentLine.length);
	}

	private void getNextLine() {
		char[] tmp = this.file.readLine();
		if(tmp !is null) {
			this.currentLine = toUTF32Array(tmp);
			this.charIdx = 0;
		} else {
			this.currentLine = null;
		}
		this.lineNumber++;
	}

	private dchar getCurrentChar() {
		if(this.isEmpty()) {
			return eof;
		} else if(this.charIdx >= this.currentLine.length) {
			this.getNextLine();
			return eol;
		} else {
			return this.currentLine[this.charIdx];
		}
	}

	private dchar getNextChar() {
		if(!this.inputChar.isEmpty()) {
			return this.inputChar.pop();
		} else if(this.isEmpty()) {
			return eof;
		} else if(this.charIdx >= this.currentLine.length) {
			this.getNextLine();
			return eol;
		} else {
			assert(this.charIdx < this.currentLine.length, 
				conv!(size_t,string)(this.charIdx) ~ " " ~
				conv!(size_t,string)(this.currentLine.length));

			return this.currentLine[this.charIdx++];
		}
	}

	public Token acceptingAction(stateType acceptingState) {
		switch(acceptingState) {
				mixin(acceptAction);
			default:
				assert(false, format("no action for %d defined",
					acceptingState));
		}
		assert(false, format("%d %s", acceptingState, 
			this.lexText.getString()));
	}

	public Location getLoc() {
		return this.loc;
	}

	public void saveLocation() {
		this.loc = Location(this.filename, this.getCurrentLineCount(),
			this.getCurrentIndexInLine());
	}

	private bool errorFunction(stateType currentState, stateType nextState, 
			dchar input) {
		auto lt = this.lexText.getString();
		size_t numberIdx = 0;
		foreach(it; lt) {
			if(isDigit(it)) {
				numberIdx++;
			} else {
				break;
			}
		}
		if(numberIdx == 0) {
			return false;
		} else if(lt[numberIdx+1 .. numberIdx+3] == "..") {
			this.pushBack(Token(this.getLoc(), terminteger, 
				stringStore.pushBack(lt[0 .. numberIdx])));
			this.pushBack(Token(this.getLoc(), termdotdot,
				stringStore.pushBack("")));
			return true;
		}

		return false;
	}

	public void getToken(Deque!(Token) toSaveIn) {
		if(this.kind) {
			bool didWait = false;
			this.mutex.lock();
			if(this.deque.isEmpty()) {
				this.isLocked = true;
				didWait = true;
				this.mutex.unlock();
				this.empty.wait();
			}
			if(didWait) {
				this.mutex.lock();
			}
			while(!this.deque.isEmpty()) {
				toSaveIn.pushBack(this.deque.popFront());	
			}
			this.mutex.unlock();
		} else { // single threaded
			this.run();
			//log("%u", this.deque.getSize());
			while(!this.deque.isEmpty()) {
				toSaveIn.pushBack(this.deque.popFront());	
			}
			return;
		}
	}

	private bool pushBack(Token token, bool last = false) {
		// only if multithreaded
		//log("%s", token.toString());
		if(this.kind) {
			this.mutex.lock();

			/*version(DOnotSTOREtoken) {
				if(this.deque.getSize() >= 1024) {
					this.deque.clean();
				}
			}*/

			// save the token
			//log("%d %s", token.getTyp(), token.getValue());
			this.deque.pushBack(token);

			// over the count or last token
			if(this.deque.getSize() > this.count || 
					token.getTyp() == termdollar) {
				//this.mutex.notify();
				if(this.isLocked) {
					this.isLocked = false;
					this.empty.notify();
				}
			}

			// unlock the buffer deque
			this.mutex.unlock();
			return false;
		} else { // not multithreaded
			//log("%d %s", token.getTyp(), token.getValue());
			this.deque.pushBack(token); // save the token
			if(this.deque.getSize() > this.count || last) {
				return true; // max count or last
			} else {
				return false; // not yet done
			}
		}
	}

	public void run() {
		stateType currentState = 0;
		stateType nextState = -1;
		this.loc = Location(this.filename, this.getCurrentLineCount(),
			1);
		while(!this.isEmpty()) {
			dchar nextChar = this.getNextChar();
			//log("%d %c", cast(int)nextChar, nextChar);
			nextState = this.getNextState(nextChar, currentState);
			//log("next state %d", nextState);
			if(nextState != -1) { // simply a next state
				currentState = nextState;
				lexText.pushBack(nextChar);
			// accepting state
			} else if(nextState == -1) { 
				//log("%s", this.lexText.getString());
				stateType accept = isAcceptingState(currentState);
				Token save;
				if(accept != -1) {
					/*log("%2d accept number %d %s", currentState, accept, 
						this.lexText.getString());
					*/
					inputChar.push(nextChar);
					save = this.acceptingAction(accept);
					//this.pushBack(save);
					this.lexText.clear();
					currentState = 0;
					this.saveLocation();
				} else {
					//log();
					if(this.errorFunction(currentState, nextState, nextChar)) {
						log();
						currentState = 0;
						this.saveLocation();
						this.lexText.clear();
					} else {
						//log();
						// to make the parser quit
						this.pushBack(Token(this.getLoc(), termdollar), true);
						send(this.parent, format( 
							"we failed with state %d and nextstate %d,"
							~ "inputchar was %c aka %d at position %s:%d:%d", 
							currentState, nextState, nextChar, 
							cast(int)nextChar, this.filename, 
							this.getCurrentLineCount(),
							this.getCurrentIndexInLine()));
						return;
					}
				}
				if(this.pushBack(save, false)) { // single step
					return;
				}
			}
		}
		//log("currentState %d", currentState);

		// we are done but there their might be a state left
		if(currentState == 0) {
			//ok I guess
			this.pushBack(Token(this.getLoc(), termdollar), true);
		} else if(isAcceptingState(currentState)) {
			Token save = this.acceptingAction(isAcceptingState(currentState));
			this.lexText.clear();
			this.pushBack(save);
			this.pushBack(Token(this.getLoc(), termdollar), true);
		} else {
			//hm not so cool
			assert(false, format("no more input when in state %d", 
				currentState));
		}
		this.file.close();
		return;
	}
}
