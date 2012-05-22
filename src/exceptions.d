module exceptions;

import hurt.string.formatter;

class LexerException : Exception {
	string msg;
	this(string text, string file = __FILE__, int line = __LINE__) {
		this.msg = format("%s at %s:%d", text, file, line);
		super(msg);
	}
}
