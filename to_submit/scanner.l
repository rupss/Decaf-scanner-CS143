/* File:  scanner.l
 * ----------------
 * Lex input file to generate the scanner for the compiler.
 */

%{

/* The text within this first region delimited by %{ and %} is assumed to
 * be C/C++ code and will be copied verbatim to the lex.yy.c file ahead
 * of the definitions of the yylex() function. Add other header file inclusions
 * or C++ variable declarations/prototypes that are needed by your code here.
 */

#include <string.h>
#include "scanner.h"
#include "utility.h" // for PrintDebug()
#include "errors.h"
#include <stdio.h>
#include <iostream>

int currLine = 0; 
int currCol = 0; 

/* Global variable: yylval
 * -----------------------
 * This global variable is how we get attribute information about the token
 * just scanned to the client. The scanner sets the global variable
 * appropriately and since it's global the client can just read it.  In the
 * future, this variable will be declared for us in the y.tab.c file
 * produced by Yacc, but for now, we declare it manually.
 */
YYSTYPE yylval;  // manually declared for pp1, later Yacc provides

/* Global variable: yylloc
 * -----------------------
 * This global variable is how we get position information about the token
 * just scanned to the client. (Operates similarly to yylval above)
 */
struct yyltype yylloc; // manually dclared for pp1, later Yacc provides

/* Macro: YY_USER_ACTION 
 * ---------------------
 * This flex built-in macro can be defined to provide an action which is
 * always executed prior to any matched rule's action. Basically, it is
 * a way of having a piece of code common to all actions factored out to
 * this routine.  We already defined it for you and left the empty
 * function DoBeforeEachAction ready for your use as needed. It will
 * be called once for each pattern scanned from the file, before
 * executing its action.
 */
static void DoBeforeEachAction(); 
#define YY_USER_ACTION DoBeforeEachAction();

%}

 /* The section before the first %% is the Definitions section of the lex
  * input file. Here is where you set options for the scanner, define lex
  * states, and can set up definitions to give names to regular expressions
  * as a simple substitution mechanism that allows for more readable
  * entries in the Rules section later. 
  */
  
X				"x"|"X"
HEX_NUM			[0-9a-fA-F]+
DOUBLE_CONST	[0-9]+[\.][0-9]*
EXP				"E"|"e"
EXP_SIGN 		"-"|"+"
BOOL_CONST		"true"|"false"
BEGIN_COMMENT	"/*"
END_COMMENT		"*/"
SINGLE_PUNCT    ([-+/*%=.,;!<>()[\]{}])
STR_CONST		\"([^\"\n])*\"
NEWLINE			[\n]
INSIDE_ID		[A-Z]|[a-z]|[_]|[0-9]
ID				[a-zA-Z]+{INSIDE_ID}*
INVALID_CHAR	[^a-zA-Z0-9_{SINGLE_PUNCT}]

%x IN_COMMENT

%%             /* BEGIN RULES SECTION */
 /* All patterns and actions should be placed between the start and stop
  * %% markers which delimit the Rules section. 
  */ 
  
<*>[ ]+				{
	
}
  
<INITIAL>\n 					{ 
	currLine++; 
	currCol = 1; 
}

<INITIAL>\t 					{
	currCol += 8;
}

<INITIAL>[0-9]+				{ 

	yylval.integerConstant = atoi(yytext); 
	
	return T_IntConstant; 
}

<INITIAL>0{X}{HEX_NUM}		{
	yylval.integerConstant = (int)strtod(yytext, NULL); 
	return T_IntConstant; 
}


<INITIAL>{DOUBLE_CONST}|[0-9]+[\.][0-9]*{EXP}{EXP_SIGN}?[0-9]+			{
	yylval.doubleConstant = strtod(yytext, NULL) ;
	return T_DoubleConstant; 
}

<INITIAL>{BOOL_CONST}		{
	if (yytext[0] == 't')
		yylval.boolConstant = true; 
	else if (yytext[0] == 'f')
		yylval.boolConstant = false; 
	return T_BoolConstant; 
}

<INITIAL>{BEGIN_COMMENT}	{
	BEGIN(IN_COMMENT); 
}

<INITIAL>{SINGLE_PUNCT}		{
	return yytext[0]; 
}

<INITIAL>"<="				{
	return T_LessEqual; 
}

<INITIAL>">="				{
	return T_GreaterEqual; 
}

<INITIAL>"=="				{

	return T_Equal; 
}

<INITIAL>"!="				{
	return T_NotEqual; 
}

<INITIAL>"&&"				{
	return T_And; 
}

<INITIAL>"||"				{
	return T_Or; 
}

<INITIAL>"[]"				{
	return T_Dims; 
}

<INITIAL>"//"[^\n]*				{
	//ignores one line comments
}

<INITIAL>"void"				{
	return T_Void; 
}

<INITIAL>"int"				{
	return T_Int; 
}

<INITIAL>"double"				{
	return T_Double; 
}

<INITIAL>"bool"				{
	return T_Bool; 
}

<INITIAL>"string"				{
	return T_String; 
}

<INITIAL>"class"				{
	return T_Class; 
}

<INITIAL>"interface"				{
	return T_Interface; 
}

<INITIAL>"null"				{
	return T_Null; 
}

<INITIAL>"this"				{
	return T_This; 
}

<INITIAL>"extends"				{
	return T_Extends; 
}

<INITIAL>"implements"				{
	return T_Implements; 
}

<INITIAL>"for"				{
	return T_For; 
}

<INITIAL>"while"				{
	return T_While; 
}

<INITIAL>"if"				{
	return T_If; 
}

<INITIAL>"else"				{
	return T_Else; 
}

<INITIAL>"return"				{
	return T_Return; 
}

<INITIAL>"break"				{
	return T_Break; 
}

<INITIAL>"new"				{
	return T_New; 
}

<INITIAL>"NewArray"				{
	return T_NewArray; 
}

<INITIAL>"Print"				{
	return T_Print; 
}

<INITIAL>"ReadInteger"				{
	return T_ReadInteger; 
}

<INITIAL>"ReadLine"				{
	return T_ReadLine; 
}


 <IN_COMMENT>{
     {END_COMMENT}      { BEGIN(INITIAL); }
     [^*\n]+   			// eat comment in chunks
     "*"       			// eat the lone star
     \n		  			{ currLine++; }
     <<EOF>>			{
     	ReportError::UntermComment(); 
     	yyterminate(); 
     	}
     }

<INITIAL>{STR_CONST}	{
	//s = s.substr(1, yyleng-2); 
	yylval.stringConstant = yytext; 
	return T_StringConstant; 
}


<INITIAL>\"(\\.|[^\"\n])*	{
	ReportError::UntermString(&yylloc, yytext); 
}

<INITIAL>{ID}		{
	if (yyleng > 31)
		ReportError::LongIdentifier(&yylloc, yytext); 
//	int a = sscanf(yytext, "%31s", yylval.identifier);  
	strncpy(yylval.identifier, yytext, 31); 
	return T_Identifier; 
}

<INITIAL>{INVALID_CHAR}	{
	ReportError::UnrecogChar(&yylloc, yytext[0]); 
}

%%
/* The closing %% above marks the end of the Rules section and the beginning
 * of the User Subroutines section. All text from here to the end of the
 * file is copied verbatim to the end of the generated lex.yy.c file.
 * This section is where you put definitions of helper functions.
 */


/* Function: InitScanner
 * ---------------------
 * This function will be called before any calls to yylex().  It is designed
 * to give you an opportunity to do anything that must be done to initialize
 * the scanner (set global variables, configure starting state, etc.). One
 * thing it already does for you is assign the value of the global variable
 * yy_flex_debug that controls whether flex prints debugging information
 * about each token and what rule was matched. If set to false, no information
 * is printed. Setting it to true will give you a running trail that might
 * be helpful when debugging your scanner. Please be sure the variable is
 * set to false when submitting your final version.
 */
void InitScanner()
{
    PrintDebug("lex", "Initializing scanner");
    yy_flex_debug = false;
    currLine = 1; 
    currCol = 1; 
}


/* Function: DoBeforeEachAction()
 * ------------------------------
 * This function is installed as the YY_USER_ACTION. This is a place
 * to group code common to all actions.
 */
static void DoBeforeEachAction()
{
 
	yylloc.first_line = currLine; 
	yylloc.last_line = currLine; 
	yylloc.first_column = currCol; 
	
	currCol += yyleng;  
	

	yylloc.last_column = currCol - 1; 

	
}
