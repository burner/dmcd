%token identifier
%token bang
%token bangless
%token banglessequal
%token bangsquare
%token bangsquareassign
%token notequal
%token banggreater
%token banggreaterassign
%token bangis
%token dollarsym
%token modulo
%token moduloassign
%token logicaland
%token and
%token andassign
%token lparen
%token rparen
%token star
%token starassign
%token plusassign
%token comma
%token minus
%token decrement
%token minusassign
%token dot
%token dotdot
%token dotdotdot
%token div
%token divassign
%token colon
%token semicolon
%token less
%token leftshift
%token leftshiftassign
%token lessequal
%token arrow
%token square
%token squareassign
%token assign
%token equal
%token greater
%token greaterequal
%token rightshift
%token rightshiftassign
%token unsignedrightshift
%token unsignedrightshiftassign
%token questionmark
%token disable
%token property
%token safe
%token system
%token trusted
%token integer
%token floatliteral
%token plus
%token increment
%token lbrack
%token rbrack
%token xor
%token xorxor
%token xorassign
%token xorxorassign
%token thread
%token traits
%token abstract
%token alias
%token align
%token asm
%token assert
%token auto
%token body
%token bool
%token break
%token byte
%token case
%token cast
%token catch
%token gshared
%token cdouble
%token cfloat
%token char
%token class
%token const
%token continue
%token creal
%token dchar
%token default
%token delegate
%token deprecated
%token do
%token double
%token enum
%token else
%token export
%token extern
%token false
%token final
%token finally
%token float
%token for
%token foreach
%token foreach_reverse
%token function
%token goto
%token idouble
%token if
%token ifloat
%token import
%token immutable
%token in
%token inout
%token int
%token size_t
%token interface
%token invariant
%token ireal
%token is
%token long
%token lazy
%token mixin
%token module
%token new
%token nothrow
%token null
%token out
%token override
%token private
%token protected
%token public
%token pragma
%token real
%token ref
%token return
%token pure
%token scope
%token short
%token static
%token struct
%token super
%token switch
%token synchronized
%token this
%token throw
%token true
%token try
%token typeid
%token typeof
%token ubyte
%token uint
%token ulong
%token union
%token unittest
%token ushort
%token void
%token wchar
%token while
%token with
%token file
%token line
%token lcurly
%token logicalor
%token orassign
%token or
%token rcurly
%token tilde
%token tildeassign
%token version
%token package
%token stringliteral
%token bangin
%token exit
%token failure
%token success
%token template
%token delete
%token shared
%token debug
%token charliteral

%glr-parser

%%

S : 
	Module;

Module :
	ModuleDeclaration DeclDefs
	| DeclDefs;

ModuleDeclaration :
	module ModuleFullyQualifiedName semicolon;

ModuleFullyQualifiedName :
	ModuleName
	| Packages dot ModuleName;

ModuleName :
	identifier;

Packages :
	PackageName
	| Packages dot PackageName;

PackageName :
	identifier;

DeclDefs :
	DeclDef
	| DeclDef DeclDefs;

DeclDef :
	AttributeSpecifier
	| ImportDeclaration
	| EnumDeclaration
	| ClassDeclaration
	| InterfaceDeclaration
	| AggregateDeclaration
	| Declaration
	| Constructor
	| Destructor
	| UnitTest
	| StaticConstructor
	| StaticDestructor
	| SharedStaticConstructor
	| SharedStaticDestructor
	| ConditionalDeclaration
	| DebugSpecification
	| VersionSpecification
	| StaticAssert
	| TemplateDeclaration
	| TemplateMixinDeclaration
	| TemplateMixin
	| MixinDeclaration
	| semicolon;

ImportDeclaration :
	import ImportList semicolon
	| static import ImportList semicolon;

ImportList :
	Import
	| ImportBindings
	| Import comma ImportList;

Import :
	ModuleFullyQualifiedName
	| ModuleAliasIdentifier assign ModuleFullyQualifiedName;

ImportBindings :
	Import colon ImportBindList;

ImportBindList :
	ImportBind
	| ImportBind comma ImportBindList;

ImportBind :
	identifier
	| identifier assign identifier;

ModuleAliasIdentifier :
	identifier;

MixinDeclaration :
	mixin lparen AssignExpression rparen semicolon;

Declaration :
	AliasDeclaration
	| AliasThisDeclaration
	| Decl;

AliasDeclaration :
	alias BasicType Declarator
	;
AliasThisDeclaration : 
	alias identifier this;

Decl : 
	StorageClasses Decl
	| BasicType Declarators semicolon
	| BasicType Declarator FunctionBody
	| AutoDeclaration;

Declarators :
	DeclaratorInitializer
	| DeclaratorInitializer comma DeclaratorIdentifierList;

DeclaratorInitializer :
	Declarator
	| Declarator assign Initializer;

DeclaratorIdentifierList :
	DeclaratorIdentifier
	| DeclaratorIdentifier comma DeclaratorIdentifierList;

DeclaratorIdentifier :
	identifier
	| identifier assign Initializer;

AutoDeclaration : 
	StorageClasses AutoDeclarationX semicolon
	;
AutoDeclarationX : identifier assign Initializer
	| AutoDeclarationX comma identifier assign Initializer;

BasicType :
	BasicTypeX
	| dot IdentifierList
	| IdentifierList
	| Typeof
	| Typeof dot IdentifierList
	| const lparen Type rparen
	| immutable lparen Type rparen
	| shared lparen Type rparen
	| inout lparen Type rparen;

BasicTypeX :
	bool
	| byte
	| ubyte
	| short
	| ushort
	| int
	| uint
	| long
	| ulong
	| char
	| wchar
	| dchar
	| float
	| size_t
	| double
	| real
	| ifloat
	| idouble
	| ireal
	| cfloat
	| cdouble
	| creal
	| void;

BasicType2 :
	star
	| lbrack rbrack 
	| lbrack AssignExpression rbrack 
	| lbrack AssignExpression dotdot AssignExpression rbrack
	| lbrack Type rbrack 
	| delegate Parameters FunctionAttributes
	| function Parameters FunctionAttributes
	| delegate Parameters
	| function Parameters;

Declarator :
	BasicType2 identifier
	| BasicType2 identifier DeclaratorSuffixes
	| BasicType2 lparen Declarator rparen
	| BasicType2 lparen Declarator rparen DeclaratorSuffixes
	| identifier 
	| identifier DeclaratorSuffixes
	| lparen Declarator rparen
	| lparen Declarator rparen DeclaratorSuffixes;

DeclaratorSuffixes :
	DeclaratorSuffix
	| DeclaratorSuffix DeclaratorSuffixes;

DeclaratorSuffix :
	lbrack rbrack
	| lbrack AssignExpression rbrack
	| lbrack Type rbrack
	| Parameters
	| Parameters Constraint
	| Parameters MemberFunctionAttributes Constraint
	| Parameters MemberFunctionAttributes
	| TemplateParameterList Parameters Constraint
	| TemplateParameterList Parameters MemberFunctionAttributes
	| TemplateParameterList Parameters MemberFunctionAttributes Constraint
	| TemplateParameterList Parameters;

IdentifierList :
	identifier 
	| identifier dot IdentifierList
	| TemplateInstance 
	| TemplateInstance dot IdentifierList;

StorageClasses :
	StorageClass
	| StorageClass StorageClasses;

StorageClass :
	abstract
	| auto
	| const
	| deprecated
	| enum
	| extern
	| final
	| immutable
	| inout
	| shared
	| nothrow
	| override
	| pure
	| gshared
	| Property
	| scope
	| static
	| synchronized;

Property :
	disable
	| safe
	| system
	| trusted
	| property;

Type :
	BasicType
	| BasicType Declarator2;

Declarator2 :
	BasicType2 DeclaratorSuffixes
	| BasicType2
	| DeclaratorSuffixes
	| BasicType2 lparen Declarator2 rparen DeclaratorSuffixes
	| lparen Declarator2 rparen DeclaratorSuffixes
	| BasicType2 lparen Declarator2 rparen
	| lparen Declarator2 rparen
	| BasicType2 lparen rparen DeclaratorSuffixes
	| lparen rparen DeclaratorSuffixes
	| BasicType2 lparen rparen
	| lparen rparen;

Parameters :
	lparen ParameterList rparen
	| lparen rparen;

ParameterList :
	Parameter
	| Parameter comma ParameterList
	| dotdotdot;

Parameter :
	InOut BasicType Declarator
	| InOut BasicType Declarator dotdotdot
	| InOut BasicType Declarator assign DefaultInitializerExpression
	| InOut Type
	| InOut Type dotdotdot
	| BasicType Declarator
	| BasicType Declarator dotdotdot
	| BasicType Declarator assign DefaultInitializerExpression
	| Type
	| Type dotdotdot;

InOut :
	InOutX
	| InOut InOutX;

InOutX :
	auto
	| const
	| final
	| immutable
	| in
	| inout
	| lazy
	| out
	| ref
	| scope
	| shared;

FunctionAttributes :
	FunctionAttribute
	| FunctionAttribute FunctionAttributes;

FunctionAttribute :
	nothrow
	| pure
	| Property;

MemberFunctionAttributes :
	MemberFunctionAttribute
	| MemberFunctionAttribute MemberFunctionAttributes;

MemberFunctionAttribute :
	const
	| immutable
	| inout
	| shared
	| FunctionAttribute;

DefaultInitializerExpression : 
	AssignExpression
	| file
	| line;

Initializer :
	VoidInitializer
	| NonVoidInitializer;

NonVoidInitializer :
	AssignExpression
	| ArrayInitializer
	| StructInitializer;

ArrayInitializer :
	lbrack rbrack
	| lbrack ArrayMemberInitializations rbrack;

ArrayMemberInitializations :
	ArrayMemberInitialization
	| ArrayMemberInitialization comma
	| ArrayMemberInitialization comma ArrayMemberInitializations;

ArrayMemberInitialization :
	NonVoidInitializer
	| AssignExpression colon NonVoidInitializer;

StructInitializer :
	lcurly rcurly
	| lcurly StructMemberInitializers rcurly;

StructMemberInitializers :
	StructMemberInitializer
	| StructMemberInitializer comma
	| StructMemberInitializers comma StructMemberInitializer;

StructMemberInitializer :
	NonVoidInitializer
	| identifier colon NonVoidInitializer;

Typeof :
	typeof lparen Expression rparen
	| typeof lparen return rparen;

VoidInitializer :
	void;

AttributeSpecifier :
	Attribute colon
	| Attribute DeclarationBlock;

Attribute :
	LinkageAttribute
	| AlignAttribute
	| Pragma
	| deprecated
	| ProtectionAttribute
	| static
	| extern
	| final
	| synchronized
	| override
	| abstract
	| const
	| auto
	| scope
	| gshared
	| shared
	| immutable
	| inout
	| disable;

DeclarationBlock :
	DeclDef
	| lcurly DeclDefs rcurly
	| lcurly rcurly;

LinkageAttribute :
	extern lparen identifier rparen;

AlignAttribute :
	align
	| align lparen integer rparen;

ProtectionAttribute :
	export
	| package
	| private
	| protected
	| public;

Pragma :
	pragma lparen identifier rparen
	| pragma lparen identifier comma ArgumentList rparen;

Expression :
	CommaExpression;

CommaExpression :
	AssignExpression
	| AssignExpression comma CommaExpression;

AssignExpression :
	ConditionalExpression
	| ConditionalExpression assign AssignExpression
	| ConditionalExpression plusassign AssignExpression
	| ConditionalExpression minusassign AssignExpression
	| ConditionalExpression starassign AssignExpression
	| ConditionalExpression divassign AssignExpression
	| ConditionalExpression moduloassign AssignExpression
	| ConditionalExpression andassign AssignExpression
	| ConditionalExpression orassign AssignExpression
	| ConditionalExpression xorassign AssignExpression
	| ConditionalExpression tildeassign AssignExpression
	| ConditionalExpression leftshiftassign AssignExpression
	| ConditionalExpression rightshiftassign AssignExpression
	| ConditionalExpression unsignedrightshiftassign AssignExpression
	| ConditionalExpression xorxorassign AssignExpression;

ConditionalExpression :
	OrOrExpression
	| OrOrExpression questionmark Expression colon ConditionalExpression;

OrOrExpression :
	AndAndExpression
	| OrOrExpression logicalor AndAndExpression;

AndAndExpression :
	OrExpression
	| AndAndExpression logicaland OrExpression
	| CmpExpression
	| AndAndExpression logicaland CmpExpression;

OrExpression :
	XorExpression
	| OrExpression or XorExpression;

XorExpression :
	AndExpression
	| XorExpression xor AndExpression;

AndExpression :
	ShiftExpression 
	| AndExpression and ShiftExpression;

CmpExpression :
	ShiftExpression
	| EqualExpression
	| IdentityExpression
	| RelExpression
	| InExpression;

EqualExpression :
	ShiftExpression equal ShiftExpression
	| ShiftExpression notequal ShiftExpression;

IdentityExpression :
	ShiftExpression is ShiftExpression
	| ShiftExpression bangis ShiftExpression;

RelExpression :
	ShiftExpression less ShiftExpression
	| ShiftExpression lessequal ShiftExpression
	| ShiftExpression greater ShiftExpression
	| ShiftExpression greaterequal ShiftExpression
	| ShiftExpression bangsquareassign ShiftExpression
	| ShiftExpression bangsquare ShiftExpression
	| ShiftExpression square ShiftExpression
	| ShiftExpression squareassign ShiftExpression
	| ShiftExpression banggreater ShiftExpression
	| ShiftExpression banggreaterassign ShiftExpression
	| ShiftExpression bangless ShiftExpression
	| ShiftExpression banglessequal ShiftExpression;

InExpression :
	ShiftExpression in ShiftExpression
	| ShiftExpression bangin ShiftExpression;

ShiftExpression :
	AddExpression
	| ShiftExpression leftshift AddExpression
	| ShiftExpression rightshift AddExpression
	| ShiftExpression unsignedrightshift AddExpression;

AddExpression :
	MulExpression
	| CatExpression
	| AddExpression plus MulExpression
	| AddExpression minus MulExpression;

CatExpression :
	AddExpression tilde MulExpression;

MulExpression :
	UnaryExpression
	| MulExpression star UnaryExpression
	| MulExpression div UnaryExpression
	| MulExpression modulo UnaryExpression;

PowExpression :
	PostfixExpression
	| PostfixExpression xorxor UnaryExpression;

UnaryExpression :
	and UnaryExpression
	| increment UnaryExpression
	| decrement UnaryExpression
	| star UnaryExpression
	| minus UnaryExpression
	| plus UnaryExpression
	| bang UnaryExpression
	| ComplementExpression
	| lparen Type rparen dot identifier
	| NewExpression
	| DeleteExpression
	| CastExpression
	| PowExpression;

ComplementExpression : 
	tilde UnaryExpression;

NewExpression : 
	new AllocatorArguments Type lbrack AssignExpression rbrack
	| new Type lbrack AssignExpression rbrack
	| new AllocatorArguments Type lparen ArgumentList lparen
	| new Type lparen ArgumentList lparen
	| new AllocatorArguments Type
	| new Type
	| NewAnonClassExpression;

AllocatorArguments :
	lparen ArgumentList rparen
	| lparen rparen;

ArgumentList :
	AssignExpression 
	| AssignExpression comma
	| AssignExpression comma ArgumentList;

DeleteExpression :
	delete UnaryExpression;

CastExpression :
	cast lparen Type rparen UnaryExpression
	| cast lparen CastQual rparen UnaryExpression
	| cast lparen rparen UnaryExpression;

CastQual :
	const
	| const shared
	| shared const
	| inout
	| inout shared
	| shared inout
	| immutable
	| shared;

PostfixExpression :
	PrimaryExpression
	| PostfixExpression dot identifier
	| PostfixExpression dot TemplateInstance
	| PostfixExpression dot NewExpression
	| PostfixExpression increment
	| PostfixExpression decrement
	| PostfixExpression lparen rparen
	| PostfixExpression lparen ArgumentList rparen
	| IndexExpression
	| SliceExpression;

IndexExpression :
	PostfixExpression lbrack ArgumentList rbrack;

SliceExpression :
	PostfixExpression lbrack rbrack
	| PostfixExpression lbrack AssignExpression dotdot AssignExpression rbrack;

PrimaryExpression :
	identifier
	| dot identifier
	| TemplateInstance
	| dot TemplateInstance
	| this
	| super
	| null
	| true
	| false
	| dollarsym
	| file
	| line
	| integer
	| floatliteral
	| charliteral
	| stringliteral
	| ArrayLiteral
	| AssocArrayLiteral
	| Lambda
	| FunctionLiteral
	| AssertExpression
	| MixinExpression
	| ImportExpression
	| BasicType dot identifier
	| Typeof
	| TypeidExpression
	| IsExpression
	| lparen Expression rparen
	| TraitsExpression;

ArrayLiteral :
	lbrack ArgumentList rbrack;

AssocArrayLiteral :
	lbrack KeyValuePairs rbrack;

KeyValuePairs :
	KeyValuePair
	| KeyValuePair comma KeyValuePairs;

KeyValuePair :
	KeyExpression colon ValueExpression;

KeyExpression :
	AssignExpression;

ValueExpression :
	AssignExpression;

Lambda :
	identifier arrow AssignExpression
	| ParameterAttributes arrow AssignExpression;

FunctionLiteral :
	function Type ParameterAttributes FunctionBody
	| function ParameterAttributes FunctionBody
	| function Type FunctionBody
	| function FunctionBody
	| delegate Type ParameterAttributes FunctionBody
	| delegate ParameterAttributes FunctionBody
	| delegate Type FunctionBody
	| delegate FunctionBody
	| ParameterAttributes FunctionBody
	| FunctionBody;

ParameterAttributes :
	Parameters
	| Parameters FunctionAttributes;

AssertExpression :
	assert lparen AssignExpression rparen
	| assert lparen AssignExpression comma AssignExpression rparen;

MixinExpression :
	mixin lparen AssignExpression rparen;

ImportExpression :
	import lparen AssignExpression rparen;

TypeidExpression :
	typeid lparen Type rparen
	| typeid lparen Expression rparen;

IsExpression :
	is lparen Type rparen
	| is lparen Type colon TypeSpecialization rparen
	| is lparen Type equal TypeSpecialization rparen
	| is lparen Type identifier rparen
	| is lparen Type identifier colon TypeSpecialization rparen
	| is lparen Type identifier equal TypeSpecialization rparen
	| is lparen Type identifier colon TypeSpecialization comma TemplateParameterList rparen
	| is lparen Type identifier equal TypeSpecialization comma TemplateParameterList rparen;

TypeSpecialization :
	Type
	| class
	| const
	| delegate
	| enum
	| function
	| immutable
	| inout
	| interface
	| return
	| shared
	| struct
	| super
	| union;

TraitsExpression :
	traits lparen TraitsKeyword comma TraitsArguments rparen;

TraitsKeyword :
	identifier;

TraitsArguments :
	TraitsArgument
	| TraitsArgument comma TraitsArguments;

TraitsArgument :
	AssignExpression
	| Type;

Statement :
    semicolon
    | NonEmptyStatement
    | ScopeBlockStatement;

NoScopeNonEmptyStatement :
    NonEmptyStatement
    | BlockStatement;

NoScopeStatement :
    semicolon
    | NonEmptyStatement
    | BlockStatement;

NonEmptyOrScopeBlockStatement :
    NonEmptyStatement
    | ScopeBlockStatement;

NonEmptyStatement :
    NonEmptyStatementNoCaseNoDefault
    | CaseStatement
    | CaseRangeStatement
    | DefaultStatement;

NonEmptyStatementNoCaseNoDefault :
    LabeledStatement
    | ExpressionStatement
    | DeclarationStatement
    | IfStatement
    | WhileStatement
    | DoStatement
    | ForStatement
    | ForeachStatement
    | SwitchStatement
    | FinalSwitchStatement
    | ContinueStatement
    | BreakStatement
    | ReturnStatement
    | GotoStatement
    | WithStatement
    | SynchronizedStatement
    | TryStatement
    | ScopeGuardStatement
    | ThrowStatement
    | AsmStatement
    | PragmaStatement
    | MixinStatement
    | ForeachRangeStatement
    | ConditionalStatement
    | StaticAssert
    | TemplateMixin
    | ImportDeclaration;

ScopeStatement :
    NonEmptyStatement
    | BlockStatement;

ScopeBlockStatement :
    BlockStatement;

LabeledStatement :
	identifier colon NoScopeStatement;

BlockStatement :
	lcurly rcurly 
	| lcurly StatementList rcurly;

StatementList :
	Statement
	| Statement StatementList;

ExpressionStatement :
	Expression semicolon;

DeclarationStatement :
	Declaration;

IfStatement :
	if lparen IfCondition rparen ThenStatement
	| if lparen IfCondition rparen ThenStatement else ElseStatement;

IfCondition :
	Expression
	| auto identifier assign Expression
	| BasicType Declarator assign Expression;

ThenStatement :
	ScopeStatement;

ElseStatement :
	ScopeStatement;

WhileStatement :
	while lparen Expression rparen ScopeStatement;

DoStatement :
	do ScopeStatement while lparen Expression rparen semicolon;

ForStatement :
    for lparen Initialize Test semicolon Increment rparen ScopeStatement
    | for lparen Initialize Test semicolon rparen ScopeStatement
    | for lparen Initialize semicolon Increment rparen ScopeStatement
    | for lparen Initialize semicolon rparen ScopeStatement;

Initialize :
	semicolon
	| NoScopeNonEmptyStatement;
// expression was opt;
Test :
	Expression;
// expression was opt;
Increment :
	Expression;

ForeachStatement :
	Foreach lparen ForeachTypeList semicolon Aggregate rparen NoScopeNonEmptyStatement;

Foreach :
	foreach
	| foreach_reverse;

ForeachTypeList :
	ForeachType
	| ForeachType comma ForeachTypeList;

ForeachType :
	ref BasicType Declarator
	| ref identifier
	| BasicType identifier
	| identifier;

Aggregate :
	Expression;

SwitchStatement :
	switch lparen Expression rparen ScopeStatement;

CaseStatement :
	case ArgumentList colon ScopeStatementList;

CaseRangeStatement :
	case FirstExp colon dotdot case LastExp colon ScopeStatementList;

FirstExp :
	AssignExpression;

LastExp :
	AssignExpression;

DefaultStatement :
	default colon ScopeStatementList;

ScopeStatementList :
    StatementListNoCaseNoDefault;

StatementListNoCaseNoDefault :
    StatementNoCaseNoDefault
    | StatementNoCaseNoDefault StatementListNoCaseNoDefault;

StatementNoCaseNoDefault :
    semicolon
    | NonEmptyStatementNoCaseNoDefault
    | ScopeBlockStatement;

FinalSwitchStatement :
	final switch lparen Expression rparen ScopeStatement;

ContinueStatement :
	continue semicolon
	| continue identifier semicolon;

BreakStatement :
	break semicolon
	| break identifier semicolon;

ReturnStatement :
	return semicolon
	| return Expression semicolon;

GotoStatement :
	goto identifier semicolon
	| goto default semicolon
	| goto case semicolon
	| goto case Expression semicolon;

WithStatement :
	with lparen Expression rparen ScopeStatement
	| with lparen Symbol rparen ScopeStatement
	| with lparen TemplateInstance rparen ScopeStatement;

SynchronizedStatement :
	synchronized ScopeStatement
	| synchronized lparen Expression rparen ScopeStatement;

TryStatement :
	try ScopeStatement Catches
	| try ScopeStatement Catches FinallyStatement
	| try ScopeStatement FinallyStatement;

Catches :
	LastCatch
	| Catch
	| Catch Catches;

LastCatch :
	catch NoScopeNonEmptyStatement;

Catch :
	catch lparen CatchParameter rparen NoScopeNonEmptyStatement;

CatchParameter :
	BasicType identifier;

FinallyStatement :
	finally NoScopeNonEmptyStatement;

ThrowStatement :
	throw Expression semicolon;

ScopeGuardStatement :
	scope lparen exit rparen NonEmptyOrScopeBlockStatement
	| scope lparen success rparen NonEmptyOrScopeBlockStatement
	| scope lparen failure rparen NonEmptyOrScopeBlockStatement;

AsmStatement :
	asm lcurly rcurly
	| asm lcurly AsmInstructionList rcurly;

AsmInstructionList :
	AsmInstruction semicolon
	| AsmInstruction semicolon AsmInstructionList;

PragmaStatement :
	Pragma NoScopeStatement;

MixinStatement :
	mixin lparen AssignExpression rparen semicolon;

ForeachRangeStatement :
	Foreach lparen ForeachType semicolon LwrExpression dotdot UprExpression rparen ScopeStatement;

LwrExpression :
	Expression;

UprExpression :
	Expression;

AggregateDeclaration :
	struct identifier StructBody
	| union identifier StructBody
	| struct identifier semicolon
	| union identifier semicolon
	| StructTemplateDeclaration
	| UnionTemplateDeclaration;

StructBody :
	lcurly StructBodyDeclarations rcurly
	| lcurly rcurly;

StructBodyDeclarations :
	StructBodyDeclaration
	| StructBodyDeclaration StructBodyDeclarations;

StructBodyDeclaration :
	DeclDef
	| StructAllocator
	| StructDeallocator
	| StructPostblit
	| AliasThis
	;
StructAllocator : 
	ClassAllocator;
	
StructDeallocator :
	ClassDeallocator;

StructPostblit :
	this lparen this rparen FunctionBody;

ClassDeclaration :
	class identifier BaseClassList ClassBody
	| class identifier ClassBody
	| ClassTemplateDeclaration;

BaseClassList :
	colon SuperClass
	| colon SuperClass comma Interfaces
	| Interfaces;

SuperClass :
	identifier;

Interfaces :
	Interface
	| Interface comma Interfaces;

Interface :
	identifier;

ClassBody :
	lcurly rcurly
	| lcurly ClassBodyDeclarations rcurly;

ClassBodyDeclarations :
	ClassBodyDeclaration
	| ClassBodyDeclaration ClassBodyDeclarations;

ClassBodyDeclaration :
	DeclDef
	| Invariant
	| ClassAllocator
	| ClassDeallocator;

Constructor :
	this Parameters FunctionBody
	| TemplatedConstructor;

TemplatedConstructor :
    this lparen TemplateParameterList rparen Parameters Constraint FunctionBody
    | this lparen TemplateParameterList rparen Parameters FunctionBody;

Destructor :
	tilde this lparen rparen FunctionBody;

StaticConstructor :
	static this lparen rparen FunctionBody;

StaticDestructor :
	static tilde this lparen rparen FunctionBody;

SharedStaticConstructor :
	shared static this lparen rparen FunctionBody;

SharedStaticDestructor :
	shared static tilde this lparen rparen FunctionBody;

Invariant :
	invariant lparen rparen BlockStatement;

ClassAllocator :
	new Parameters FunctionBody;

ClassDeallocator :
	delete Parameters FunctionBody;

AliasThis :
	alias identifier this semicolon;

NewAnonClassExpression :
	new AllocatorArguments class ClassArguments Interfaces ClassBody
	| new AllocatorArguments class ClassArguments SuperClass ClassBody
	| new AllocatorArguments class ClassArguments SuperClass Interfaces ClassBody
	| new AllocatorArguments class Interfaces ClassBody
	| new AllocatorArguments class SuperClass ClassBody
	| new AllocatorArguments class SuperClass Interfaces ClassBody
	| new class ClassArguments Interfaces ClassBody
	| new class ClassArguments SuperClass ClassBody
	| new class ClassArguments SuperClass Interfaces ClassBody
	| new class ClassBody
	| new class SuperClass Interfaces ClassBody;

ClassArguments :
	lparen ArgumentList rparen
	| lparen rparen;

InterfaceDeclaration :
	interface identifier BaseInterfaceList InterfaceBody
	| interface identifier InterfaceBody
	| InterfaceTemplateDeclaration;

BaseInterfaceList :
	colon BaseClassList;

InterfaceBody :
	lcurly DeclDefs rcurly
	| lcurly rcurly;

EnumDeclaration : enum EnumBody
	| enum EnumTag EnumBody
	| enum EnumTag colon EnumBaseType EnumBody
	| enum colon EnumBaseType EnumBody;

EnumTag :
	identifier;

EnumBaseType :
	Type;

EnumBody :
	semicolon
	| lcurly EnumMembers rcurly;

EnumMembers :
	EnumMember
	| EnumMembers comma
	| EnumMembers comma EnumMember;

EnumMember :
	 identifier
	 | identifier assign AssignExpression
	 | Type assign AssignExpression;

FunctionBody :
	 BlockStatement 
	 | BodyStatement
	 | InStatement BodyStatement
	 | OutStatement BodyStatement
	 | InStatement OutStatement BodyStatement
	 | OutStatement InStatement BodyStatement;

InStatement :
	 in BlockStatement;

OutStatement :
	 out BlockStatement
	 | out lparen identifier rparen BlockStatement;

BodyStatement :
	 body BlockStatement;

ConditionalDeclaration :
	 Condition CCDeclarationBlock
	 | Condition CCDeclarationBlock else CCDeclarationBlock
	 | Condition colon Declarations;

CCDeclarationBlock :
	Declaration
	| lcurly Declarations rcurly
	| lcurly rcurly;

Declarations :
	Declaration
	| Declaration Declarations;

ConditionalStatement :
	 Condition NoScopeNonEmptyStatement
	 | Condition NoScopeNonEmptyStatement else NoScopeNonEmptyStatement;

Condition :
	 VersionCondition
	 | DebugCondition
	 | StaticIfCondition;

VersionCondition :
	 version lparen integer rparen
	 | version lparen identifier rparen
	 | version lparen unittest rparen;

VersionSpecification :
	 version assign identifier semicolon
	 | version assign integer semicolon;

DebugCondition :
	 debug
	 | debug lparen integer rparen
	 | debug lparen identifier rparen;

DebugSpecification :
	 debug assign identifier semicolon
	 | debug assign integer semicolon;

StaticIfCondition :
	 static if lparen AssignExpression rparen;

StaticAssert :
	 static assert lparen AssignExpression rparen semicolon
	 | static assert lparen AssignExpression comma AssignExpression rparen semicolon;

TemplateDeclaration :
	template TemplateIdentifier lparen TemplateParameterList rparen Constraint lcurly DeclDefs rcurly
	| template TemplateIdentifier lparen TemplateParameterList rparen lcurly DeclDefs rcurly;

TemplateIdentifier :
	identifier;

TemplateParameterList :
	TemplateParameter
	| TemplateParameter comma
	| TemplateParameter comma TemplateParameterList;

TemplateParameter :
	TemplateTypeParameter
	| TemplateValueParameter
	| TemplateAliasParameter
	| TemplateTupleParameter
	| TemplateThisParameter;

TemplateTupleParameter :
	identifier dotdotdot;
//IdentifierOrTemplateInstance :
//	identifier
//	| TemplateInstance;

TemplateInstance :
	TemplateIdentifier bang lparen TemplateArgumentList rparen
	| TemplateIdentifier bang TemplateSingleArgument;

TemplateThisParameter :
    this TemplateTypeParameter;

TemplateArgumentList :
	TemplateArgument
	| TemplateArgument comma
	| TemplateArgument comma TemplateArgumentList;

TemplateArgument :
	Type
	| AssignExpression
	| Symbol;

Symbol :
	SymbolTail
	| dot SymbolTail;

SymbolTail :
	identifier
	| identifier dot SymbolTail
	| TemplateInstance
	| TemplateInstance dot SymbolTail;

TemplateSingleArgument :
	identifier
	| BasicTypeX
	| charliteral
	| stringliteral
	| integer
	| floatliteral
	| true
	| false
	| null
	| file
	| line;

TemplateTypeParameter :
	identifier
	| identifier TemplateTypeParameterSpecialization
	| identifier TemplateTypeParameterDefault
	| identifier TemplateTypeParameterSpecialization TemplateTypeParameterDefault;

TemplateTypeParameterSpecialization :
	colon Type;

TemplateTypeParameterDefault :
	assign Type;

TemplateValueParameter :
    BasicType Declarator
    | BasicType Declarator TemplateValueParameterSpecialization
    | BasicType Declarator TemplateValueParameterDefault
    | BasicType Declarator TemplateValueParameterSpecialization TemplateValueParameterDefault;

TemplateValueParameterSpecialization :
    colon ConditionalExpression;
// already part of conditionalexpression;
TemplateValueParameterDefault :
	assign file
	| assign line
	| assign AssignExpression;

TemplateAliasParameter :
	alias BasicType Declarator TemplateAliasParameterSpecialization TemplateAliasParameterDefault
	| alias identifier TemplateAliasParameterSpecialization TemplateAliasParameterDefault
	| alias identifier TemplateAliasParameterSpecialization
	| alias identifier TemplateAliasParameterDefault
	| alias identifier
	| alias BasicType Declarator TemplateAliasParameterDefault
	| alias BasicType Declarator TemplateAliasParameterSpecialization
	| alias BasicType Declarator;

TemplateAliasParameterSpecialization :
	colon Type
	| colon ConditionalExpression;

TemplateAliasParameterDefault :
	assign Type
	| assign ConditionalExpression;

ClassTemplateDeclaration :
	class identifier lparen TemplateParameterList rparen Constraint BaseClassList ClassBody
	| class identifier lparen TemplateParameterList rparen BaseClassList ClassBody
	| class identifier lparen TemplateParameterList rparen Constraint ClassBody
	| class identifier lparen TemplateParameterList rparen ClassBody;

StructTemplateDeclaration :
	struct identifier lparen TemplateParameterList rparen Constraint StructBody
	| struct identifier lparen TemplateParameterList rparen StructBody;

UnionTemplateDeclaration :
	union identifier lparen TemplateParameterList rparen Constraint StructBody
	| union identifier lparen TemplateParameterList rparen StructBody;

InterfaceTemplateDeclaration :
	interface identifier lparen TemplateParameterList rparen Constraint BaseInterfaceList InterfaceBody
	| interface identifier lparen TemplateParameterList rparen Constraint InterfaceBody
	| interface identifier lparen TemplateParameterList rparen InterfaceBody
	| interface identifier lparen TemplateParameterList rparen BaseInterfaceList InterfaceBody;

TemplateMixinDeclaration :
	mixin template TemplateIdentifier lparen TemplateParameterList rparen Constraint lcurly DeclDefs rcurly
	| mixin template TemplateIdentifier lparen TemplateParameterList rparen lcurly DeclDefs rcurly;

Constraint :
	if lparen ConstraintExpression rparen;

ConstraintExpression :
	Expression;

TemplateMixin :
	mixin TemplateIdentifier semicolon
	| mixin TemplateIdentifier identifier semicolon
	| mixin TemplateIdentifier bang lparen TemplateArgumentList rparen semicolon
	| mixin TemplateIdentifier bang lparen TemplateArgumentList rparen semicolon identifier;

UnitTest :
	unittest FunctionBody;

AsmInstruction :
	stringliteral;
