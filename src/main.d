module main;

import std.concurrency;

import hurt.io.stdio;
import hurt.util.slog;
import hurt.container.deque;
import hurt.time.stopwatch;
import hurt.io.stdio;
import hurt.util.getopt;
import hurt.util.slog;

import lexer;
import token;
import parser;
import exceptions;

int main(string[] args) {
	Args arg = Args(args);
	bool lpMulti = true; // true means multithreaded
	arg.setOption("-l", "--lpMulti", "if false is passed" ~
		" a single threaded lexer parser combination will be created." ~
		" if nothing or true is passed the lexer parser combination will" ~
		" be multithreaded.", lpMulti);

	string file = "examplearith.dpp";
	arg.setOption("-f", "--file", "pass a string do define the file you " ~
		"want to parse. Default is examplearith.dpp" , file);

	size_t numToken = 10;
	arg.setOption("-t", "--token", "the number of token lexed in one run of" ~
		" lexer. Default is 10" , numToken, true);

	StopWatch sw;
	sw.start();
	bool succ = false;
	Lexer l = new Lexer(file, lpMulti, 10, thisTid);
	if(lpMulti) {
		l.start();
	}
	Parser p = new Parser(l, thisTid);
	p.start();

	bool needToReceiveMore = true;
	while(needToReceiveMore) {
		receive( (string s) { log("%s", s);
				return 1; },
			(bool success) { succ = success; needToReceiveMore = false; });
	}

	if(lpMulti) {
		l.join();
	}
	p.join();

	printfln("lexing and parsing took %f seconds", sw.stop());
	if(succ) {
		p.getAst().toGraph("test1.dot");
		return 0;
	}

	return 1;
}
