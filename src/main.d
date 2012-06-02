module main;

import std.concurrency;
import std.getopt;

import hurt.io.stdio;
import hurt.util.slog;
import hurt.container.deque;
import hurt.time.stopwatch;
import hurt.io.stdio;
import hurt.util.getopt;
import hurt.util.slog;
import hurt.util.util;

import exceptions;
import lexer;
import parser;
import token;
import util;

int main(string[] args) {
	string file = "examplearith.dpp";
	StopWatch arSw;
	arSw.start();
	Args arg = Args(args);
	bool lpMulti = true; // true means multithreaded
	arg.setOption("-l", "--lpMulti", "if false is passed" ~
		" a single threaded lexer parser combination will be created." ~
		" if nothing or true is passed the lexer parser combination will" ~
		" be multithreaded.", lpMulti);

	uint numToken = 10;
	arg.setOption("-t", "--token", "the number of token lexed in one run of" ~
		" lexer. Default is 10" , numToken, true);

	log("arg parsing took %f", arSw.stop());
	foreach(string it; arg) {
		log("input file %s", it);
		file = it;
	}

	StopWatch sw;
	sw.start();
	bool succ = false;
	Lexer l = new Lexer(file, lpMulti, numToken, thisTid);
	if(lpMulti) {
		l.start();
	}
	Parser p = new Parser(l, thisTid);
	p.start();

	bool needToReceiveMore = true;
	int lexerror = 0;
	while(needToReceiveMore) {
		receive( 
			(string s) { 
				log("%s", s);
				lexerror = 1; 
			},
			(bool success) { 
				succ = success; 
				needToReceiveMore = false; 
			}
		);
	}

	if(lpMulti) {
		l.join();
	}
	p.join();

	printfln("lexing and parsing took %f seconds", sw.stop());
	if(lexerror != 0) {
		exit(lexerror);
	}
	if(succ) {
		p.getAst().toGraph(removePath(file)~".dot");
	} else {
		exit(33);
	}

	return 65;
}
