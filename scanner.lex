%{
#include "tokens.hpp"
#include "output.hpp"
%}

%option yylineno
%option noyywrap

whitespace          [\t\n\r ]
printable           [\x20-\x7E\t\n\r]

%x STRING

%%

"void"                      return VOID;
"int"                       return INT;
"byte"                      return BYTE;
"bool"                      return BOOL;
"and"                       return AND;
"or"                        return OR;
"not"                       return NOT;
"true"                      return TRUE;
"false"                     return FALSE;
"return"                    return RETURN;
"if"                        return IF;
"else"                      return ELSE;
"while"                     return WHILE;
"break"                     return BREAK;
"continue"                  return CONTINUE;
";"                         return SC;
","                         return COMMA;
"("                         return LPAREN;
")"                         return RPAREN;
"{"                         return LBRACE;
"}"                         return RBRACE;
"=="|"!="|"<"|">"|"<="|">=" return RELOP;
"="                         return ASSIGN;
"+"|"-"|"*"|"/"             return BINOP;
\/\/[^\r\n]*                return COMMENT;
[a-zA-Z][a-zA-Z0-9]*        return ID;
0|[1-9][0-9]*               return NUM;
(0|[1-9][0-9]*)b            return NUM_B;

TODO: finish STRING, handle unknown words (check error handling)
// DO NOT USE FUNCTIONS HERE. scanner.lex only for token identification
// calling functions will be in main.cpp (aside from error handling)
// the current code does not handle hexadecimal

string start prompt         BEGIN(STRING) //enter string mode
<STRING>rules here          ??
<STRING>string end          BEGIN(INITIAL) // exit string mode
<STRING>\r\n|\r|\n|<<EOF>>  {
                            output::errorUnclosedString();
                            exit(1);
                            } //string terminated early
<STRING>\\[^\r\n]           {
                            output::errorUndefinedEscape(yytext + 1);
                            exit(1);
                            } // Catches a backslash followed by any character that isn't a newline
                              // If it didn't match a valid escape (like \n, \t, \", \\) earlier, it's invalid
                              // the prompt to enter this maybe isnt correct. the + 1 is to ignore the \ as required



{whitespace}+               { /*do nothing since yylineno inc. is automatic*/ }
.                           {
                            output::errorUnknownChar(yytext[0]);
                            exit(1)}

%%
// User code section

