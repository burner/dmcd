module exceptions;

import hurt.string.formatter;

class LexerException(string file = __FILE__, int line = __LINE__) : Exception {
	string msg;
	this(string text) {
		this.msg = format("%s at %s:%d", text, file, line);
		super(msg);
	}
}
