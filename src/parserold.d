module parser;

import hurt.algo.binaryrangesearch;
import hurt.container.deque;
import hurt.io.stdio;
import hurt.util.pair;
import hurt.util.slog;
import hurt.string.formatter;

import ast;
import lexer;
import parsetable;
import token;

class Parser {
	private Lexer lexer;
	private Deque!(Token) tokenBuffer;
	private Deque!(int) parseStack;
	private Deque!(Token) tokenStack;
	private AST ast;

	public this(Lexer lexer) {
		this.lexer = lexer;	
		this.tokenBuffer = new Deque!(Token)(64);
		this.parseStack = new Deque!(int)(128);
		this.tokenStack = new Deque!(Token)(128);
		this.ast = new AST();
	} 

	AST getAST() {
		return this.ast;
	}

	/** do not call this direct unless you want whitespace token
	 */
	private Token getNextToken() { 
		if(this.tokenBuffer.isEmpty()) {
			this.lexer.getToken(this.tokenBuffer);
		} 
		assert(!this.tokenBuffer.isEmpty());

		return this.tokenBuffer.popFront();
	}

	private Token getToken() {
		Token t = this.getNextToken();
		while(t.getTyp() == -99) {
			t = this.getNextToken();
		}
		return t;
	}

	private TableItem getAction(const Token input) const {
		auto retError = Pair!(int,TableItem)(-42, 
			TableItem(TableType.Error, 0));

		//log("%d %d", this.parseStack.back(), input.getTyp());

		auto toSearch = Pair!(int,TableItem)(input.getTyp(), TableItem(false));
		auto row = parseTable[this.parseStack.back()];
		bool found;
		size_t foundIdx;

		auto ret = binarySearch!(Pair!(int,TableItem)[])
			(row, toSearch, retError, row.length, found, foundIdx,
			function(Pair!(int,TableItem) a, Pair!(int,TableItem) b) {
				return a.first > b.first;
			}, 
			function(Pair!(int,TableItem) a, Pair!(int,TableItem) b) {
				return a.first == b.first; });

		return ret.second;
	}

	private short getGoto(const int input) const {
		auto retError = Pair!(int,TableItem)(int.min, 
			TableItem(TableType.Error, 0));

		auto toSearch = Pair!(int,TableItem)(input, TableItem(false));
		auto row = gotoTable[this.parseStack.back()];
		bool found;
		size_t foundIdx;

		auto ret = binarySearch!(Pair!(int,TableItem))
			(row, toSearch, retError, row.length, found, foundIdx,
			function(Pair!(int,TableItem) a, Pair!(int,TableItem) b) {
				return a.first > b.first;
			}, 
			function(Pair!(int,TableItem) a, Pair!(int,TableItem) b) {
				return a.first == b.first; });

		return ret.second.getNumber();
	}

	private void runAction(short actionNum) {
		Token ret;
		switch(actionNum) {
			mixin(actionString);
			default:
				assert(false, format("no action for %d defined", actionNum));
		}
		//log("%s", ret.toString());
		this.tokenStack.popBack(rules[actionNum].length-1);
		this.tokenStack.pushBack(ret);
	}

	private void printStack() const {
		printf("parse stack: ");
		foreach(it; this.parseStack) {
			printf("%d ", it);
		}
		println();
	}

	private void printTokenStack() const {
		printf("token stack: ");
		foreach(it; this.tokenStack) {
			printf("%s ", it.toStringShort());
		}
		println();
	}

	private void reportError(const Token input) const {
		printfln("%?1!1s in state %?1!1d on input %?1!1s", "ERROR", 
			this.parseStack.back(), input.toString());
		this.printStack();
	}

	public void parse() {
		// we start at state (zero null none 0)
		this.parseStack.pushBack(0);

		TableItem action;
		Token input = this.getToken();
		//this.tokenStack.pushBack(input);
		//log("%s", input.toString());
		
		while(true) { 
			this.printStack();
			this.printTokenStack();
			//println(this.ast.toString());
			action = this.getAction(input); 
			log(false, "input %d state %d %s", input.getTyp(), 
				this.parseStack.back(), action.toString());
			if(action.getTyp() == TableType.Accept) {
				//log("%s %s", action.toString(), input.toString());
				this.parseStack.popBack(rules[action.getNumber()].length-1);
				this.runAction(action.getNumber());
				break;
			} else if(action.getTyp() == TableType.Error) {
				//log();
				this.reportError(input);
				assert(false, "ERROR");
			} else if(action.getTyp() == TableType.Shift) {
				log("%s", input.toString());
				//log();
				this.parseStack.pushBack(action.getNumber());
				this.tokenStack.pushBack(input);
				input = this.getToken();
			} else if(action.getTyp() == TableType.Reduce) {
				log();
				// do action
				// pop RHS of Production
				this.parseStack.popBack(rules[action.getNumber()].length-1);
				this.parseStack.pushBack(
					this.getGoto(rules[action.getNumber()][0]));

				// tmp token stack stuff
				this.runAction(action.getNumber());
			}
		}
		log();
		this.printStack();
		this.printTokenStack();
		//log("%s", this.ast.toString());
	}

	private Token isExprAstA() {
		Token typNT = this.tokenStack[-2];
		Token iNi = this.tokenStack[-4];
		size_t pos = this.ast.insert(iNi, termIsExpression);
		this.ast.append(typNT.getTreeIdx());
		return Token(iNi.getLoc(), termIsExpression, pos);
	}

	private Token isExprAstB() {
		Token typSpe = this.tokenStack[-2];
		Token op = this.tokenStack[-3];
		Token typNT = this.tokenStack[-4];
		Token iNi = this.tokenStack[-6];
		size_t pos = this.ast.insert(iNi, termIsExpression);
		this.ast.append(typNT.getTreeIdx());
		this.ast.append(op.getTreeIdx());
		this.ast.append(typSpe.getTreeIdx());
		return Token(iNi.getLoc(), termIsExpression, pos);
	}

	private Token isExprAstC() {
		Token iden = this.tokenStack[-2];
		Token typNT = this.tokenStack[-3];
		Token iNi = this.tokenStack[-5];
		size_t pos = this.ast.insert(iNi, termIsExpression);
		this.ast.append(typNT.getTreeIdx());
		this.ast.append(iden.getTreeIdx());
		return Token(iNi.getLoc(), termIsExpression, pos);
	}

	private Token isExprAstD() {
		Token typSpe = this.tokenStack[-2];
		Token op = this.tokenStack[-3];
		Token iden = this.tokenStack[-4];
		Token typNT = this.tokenStack[-5];
		Token iNi = this.tokenStack[-7];
		size_t pos = this.ast.insert(iNi, termIsExpression);
		this.ast.append(typNT.getTreeIdx());
		this.ast.append(iden.getTreeIdx());
		this.ast.append(op.getTreeIdx());
		this.ast.append(typSpe.getTreeIdx());
		return Token(iNi.getLoc(), termIsExpression, pos);
	}

	private Token isExprAstE() {
		Token tmpParList = this.tokenStack[-2];
		Token typSpe = this.tokenStack[-4];
		Token op = this.tokenStack[-5];
		Token iden = this.tokenStack[-6];
		Token typNT = this.tokenStack[-7];
		Token iNi = this.tokenStack[-9];
		size_t pos = this.ast.insert(iNi, termIsExpression);
		this.ast.append(tmpParList.getTreeIdx());
		this.ast.append(typSpe.getTreeIdx());
		this.ast.append(op.getTreeIdx());
		this.ast.append(iden.getTreeIdx());
		this.ast.append(typNT.getTreeIdx());
		return Token(iNi.getLoc(), termIsExpression, pos);
	}

	private Token typOfAst() {
		Token exp = this.tokenStack[-2];
		size_t pos = this.ast.insert(termTypeof);
		this.ast.append(exp.getTreeIdx());
		return Token(this.tokenStack[-4].getLoc(), termTypeof, pos);
	}

	private Token typNTAst() {
		Token baTy = this.tokenStack[-2];
		Token de2 = this.tokenStack[-1];
		size_t pos = this.ast.insert(termTypeNT);
		this.ast.append(baTy.getTreeIdx());
		this.ast.append(de2.getTreeIdx());
		return Token(baTy.getLoc(), termTypeNT, pos);
	}

	private Token basTypAst() {
		Token idLst = this.tokenStack[-1];
		size_t pos = this.ast.insert(termBasicType);
		this.ast.append(idLst.getTreeIdx());
		return Token(this.tokenStack[-2].getLoc(), termBasicType, pos);
	}
	
	private Token dec2aAst() {
		Token baTy2 = this.tokenStack[-2];
		Token de2 = this.tokenStack[-1];
		size_t pos = this.ast.insert(termDeclarator2);
		this.ast.append(baTy2.getTreeIdx());
		this.ast.append(de2.getTreeIdx());
		return Token(baTy2.getLoc(), termDeclarator2, pos);
	}

	private Token dec2bAst() {
		Token deSufOp = this.tokenStack[-1];
		Token de2 = this.tokenStack[-3];
		size_t pos = this.ast.insert(termDeclarator2);
		this.ast.append(de2.getTreeIdx());
		this.ast.append(deSufOp.getTreeIdx());
		return Token(de2.getLoc(), termDeclarator2, pos);
	}

	private Token dec2cAst() {
		Token de2 = this.tokenStack[-2];
		//Token deSuOp = this.tokenStack[-1]; TODO check this
		size_t pos = this.ast.insert(termDeclarator2);
		this.ast.append(de2.getTreeIdx());
		//this.ast.append(deSuOp.getTreeIdx());
		return Token(de2.getLoc(), termDeclarator2, pos);
	}

	private Token basTyp2a() {
		Token typNT = this.tokenStack[-2];
		size_t pos = this.ast.insert(termBasicType2);
		this.ast.append(typNT.getTreeIdx());
		return Token(typNT.getLoc(), termBasicType2, pos);
	}
	
	private Token basTyp2b() {
		Token assiExp2 = this.tokenStack[-2];
		Token assiExp1 = this.tokenStack[-4];
		size_t pos = this.ast.insert(termBasicType2);
		this.ast.append(assiExp1.getTreeIdx());
		this.ast.append(assiExp2.getTreeIdx());
		return Token(assiExp1.getLoc(), termBasicType2, pos);
	}
	
	private Token idLstAst() {
		Token idLst = this.tokenStack[-3];
		Token id = this.tokenStack[-1];
		size_t pos = this.ast.insert(termIdentifierList);
		this.ast.append(idLst.getTreeIdx());
		this.ast.append(id.getTreeIdx());
		return Token(idLst.getLoc(), termIdentifierList, pos);
	}

	private Token decSufOpaAst() {
		Token decSufOp = this.tokenStack[-2];
		Token decSuf = this.tokenStack[-1];
		size_t pos = this.ast.insert(termDeclaratorSuffixesOpt);
		this.ast.append(decSufOp.getTreeIdx());
		this.ast.append(decSuf.getTreeIdx());
		return Token(decSufOp.getLoc(), termDeclaratorSuffixesOpt, pos);
	}

	private Token decSufOpbAst() {
		Token decSuf = this.tokenStack[-1];
		size_t pos = this.ast.insert(termDeclaratorSuffixesOpt);
		this.ast.append(decSuf.getTreeIdx());
		return Token(decSuf.getLoc(), termDeclaratorSuffixesOpt, pos);
	}

	private Token basTypNoIdLsta() {
		Token idLst = this.tokenStack[-1];
		Token typOf = this.tokenStack[-2];
		size_t pos = this.ast.insert(termBasicTypeNoIdList);
		this.ast.append(idLst.getTreeIdx());
		this.ast.append(typOf.getTreeIdx());
		return Token(idLst.getLoc(), termBasicTypeNoIdList, pos);
	}

	private Token basTypNoIdLstb() {
		Token typeNT = this.tokenStack[-2];
		Token typeCon = this.tokenStack[-4];
		size_t pos = this.ast.insert(termBasicTypeNoIdList);
		this.ast.append(typeCon.getTreeIdx());
		this.ast.append(typeNT.getTreeIdx());
		return Token(typeCon.getLoc(), termBasicTypeNoIdList, pos);
	}

	private Token tmpInsAst() {
		Token tmpArgLstOpt = this.tokenStack[-2];
		Token identi = this.tokenStack[-5];
		size_t pos = this.ast.insert(termTemplateInstance);
		this.ast.append(identi.getTreeIdx());
		this.ast.append(tmpArgLstOpt.getTreeIdx());
		return Token(identi.getLoc(), termTemplateInstance, pos);
	}

	private Token tmpArgLstAst() {
		Token tmpArg = this.tokenStack[-1];
		Token tmpArgLst = this.tokenStack[-3];
		size_t pos = this.ast.insert(termTemplateArgumentList);
		this.ast.append(tmpArgLst.getTreeIdx());
		this.ast.append(tmpArg.getTreeIdx());
		return Token(tmpArgLst.getLoc(), termTemplateArgumentList, pos);
	}

	private Token impExprAst() {
		Token assiExpr = this.tokenStack[-2];
		Token importToken = this.tokenStack[-4];
		size_t pos = this.ast.insert(importToken, termMixinExpression);
		this.ast.append(assiExpr.getTreeIdx());
		return Token(importToken.getLoc(), termImportExpression, pos);
	}

	private Token mixExprAst() {
		Token assiExpr = this.tokenStack[-2];
		Token mixinToken = this.tokenStack[-4];
		size_t pos = this.ast.insert(mixinToken, termMixinExpression);
		this.ast.append(assiExpr.getTreeIdx());
		return Token(mixinToken.getLoc(), termMixinExpression, pos);
	}

	private Token asseExprAst1() {
		Token assiExpr = this.tokenStack[-2];
		Token asse = this.tokenStack[-4];
		size_t pos = this.ast.insert(asse, termAssertExpression);
		this.ast.append(assiExpr.getTreeIdx());
		return Token(asse.getLoc(), termAssertExpression, pos);
	}

	private Token asseExprAst2() {
		Token assiExpr2 = this.tokenStack[-2];
		Token assiExpr1 = this.tokenStack[-4];
		Token asse = this.tokenStack[-6];
		size_t pos = this.ast.insert(asse, termAssertExpression);
		this.ast.append(assiExpr1.getTreeIdx());
		this.ast.append(assiExpr2.getTreeIdx());
		return Token(asse.getLoc(), termAssertExpression, pos);
	}

	private Token exprExprAst() {
		Token assExpr = this.tokenStack[-1];
		Token comma = this.tokenStack[-2];
		Token expr = this.tokenStack[-3];
		size_t pos = this.ast.insert(termExpression);
		this.ast.append(assExpr.getTreeIdx());
		this.ast.append(expr.getTreeIdx());
		return Token(expr.getLoc(), termExpression, pos);
	}

	private Token assiExprAst() {
		Token assiExpr = this.tokenStack[-1];
		Token op = this.tokenStack[-2];
		Token conExpr = this.tokenStack[-3];
		size_t pos = this.ast.insert(op, termAssignExpression);
		this.ast.append(conExpr.getTreeIdx());
		this.ast.append(assiExpr.getTreeIdx());
		return Token(conExpr.getLoc(), termAssignExpression, pos);
	}

	private Token condExprAst() {
		Token condExp = this.tokenStack[-1];
		Token colon = this.tokenStack[-2];
		Token expr = this.tokenStack[-3];
		Token quest = this.tokenStack[-4];
		Token orOrExp = this.tokenStack[-5];
		size_t pos = this.ast.insert(termConditionalExpression);
		this.ast.append(orOrExp.getTreeIdx());
		this.ast.append(expr.getTreeIdx());
		this.ast.append(condExp.getTreeIdx());
		return Token(orOrExp.getLoc(), termConditionalExpression, pos);
	}

	private Token orOrExprAst() {
		Token andAndExpr = this.tokenStack[-1];
		Token op = this.tokenStack[-2];
		Token orOrExpr = this.tokenStack[-3];
		size_t pos = this.ast.insert(op, termXorExpression);
		this.ast.append(orOrExpr.getTreeIdx());
		this.ast.append(andAndExpr.getTreeIdx());
		return Token(orOrExpr.getLoc(), termXorExpression, pos);
	}

	private Token andAndExprAst() {
		Token orExpr = this.tokenStack[-1];
		Token op = this.tokenStack[-2];
		Token andAndExpr = this.tokenStack[-3];
		size_t pos = this.ast.insert(op, termXorExpression);
		this.ast.append(andAndExpr.getTreeIdx());
		this.ast.append(orExpr.getTreeIdx());
		return Token(andAndExpr.getLoc(), termXorExpression, pos);
	}

	private Token orExprAst() {
		Token xorExpr = this.tokenStack[-1];
		Token op = this.tokenStack[-2];
		Token orExpr = this.tokenStack[-3];
		size_t pos = this.ast.insert(op, termXorExpression);
		this.ast.append(orExpr.getTreeIdx());
		this.ast.append(xorExpr.getTreeIdx());
		return Token(orExpr.getLoc(), termXorExpression, pos);
	}

	private Token xorExprAst() {
		Token andExpr = this.tokenStack[-1];
		Token op = this.tokenStack[-2];
		Token xorExpr = this.tokenStack[-3];
		size_t pos = this.ast.insert(op, termXorExpression);
		this.ast.append(xorExpr.getTreeIdx());
		this.ast.append(andExpr.getTreeIdx());
		return Token(andExpr.getLoc(), termXorExpression, pos);
	}

	private Token andExprAst() {
		Token cmpExpr = this.tokenStack[-1];
		Token op = this.tokenStack[-2];
		Token andExpr = this.tokenStack[-3];
		size_t pos = this.ast.insert(op, termAndExpression);
		this.ast.append(andExpr.getTreeIdx());
		this.ast.append(cmpExpr.getTreeIdx());
		return Token(andExpr.getLoc(), termAndExpression, pos);
	}

	private Token cmpExprAst() {
		Token shiftExpr2 = this.tokenStack[-1];
		Token op = this.tokenStack[-2];
		Token shiftExpr1 = this.tokenStack[-3];
		size_t pos = this.ast.insert(op, termCmpExpression);
		this.ast.append(shiftExpr1.getTreeIdx());
		this.ast.append(shiftExpr2.getTreeIdx());
		return Token(shiftExpr1.getLoc(), termCmpExpression, pos);
	}

	private Token shiExprAst() {
		Token addExpr = this.tokenStack[-1];
		Token op = this.tokenStack[-2];
		Token shiftExpr = this.tokenStack[-3];
		size_t pos = this.ast.insert(op, termShiftExpression);
		this.ast.append(shiftExpr.getTreeIdx());
		this.ast.append(addExpr.getTreeIdx());
		return Token(shiftExpr.getLoc(), termShiftExpression, pos);
	}

	private Token addExprAst() {
		Token mulExpr = this.tokenStack[-1];
		Token op = this.tokenStack[-2];
		Token addExpr = this.tokenStack[-3];
		size_t pos = this.ast.insert(op, termAddExpression);
		this.ast.append(mulExpr.getTreeIdx());
		this.ast.append(addExpr.getTreeIdx());
		return Token(mulExpr.getLoc(), termAddExpression, pos);
	}

	private Token mulExprAst() {
		Token unExpr = this.tokenStack[-1];
		Token op = this.tokenStack[-2];
		Token mulExpr = this.tokenStack[-3];
		size_t pos = this.ast.insert(op, termMulExpression);
		this.ast.append(unExpr.getTreeIdx());
		this.ast.append(mulExpr.getTreeIdx());
		return Token(mulExpr.getLoc(), termMulExpression, pos);
	}

	private Token unExprAst() {
		Token op = this.tokenStack[-2];
		Token unExpr = this.tokenStack[-1];
		size_t pos = this.ast.insert(op, termUnaryExpression);
		this.ast.append(unExpr.getTreeIdx());
		return Token(op.getLoc(), termUnaryExpression, pos);
	}

	private Token posExprAst() {
		Token t = this.tokenStack.back();
		size_t pos = this.ast.insert(t, termPostfixExpression);
		return Token(t.getLoc(), termPostfixExpression, pos);
	}
}
