%{
#include "tokens.hpp"
#include "output.hpp"

//char string_buf[1025];
char string_buf[4097];
int buf_ptr = 0;
%}

%option yylineno
%option noyywrap

whitespace          [\t\n\r ]
printable           [\x20-\x7E\t\n\r]

%x STRING_MODE

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
(NUM)b            return NUM_B;

TODO: finish STRING_MODE, handle unknown words (check error handling)
// DO NOT USE FUNCTIONS HERE. scanner.lex only for token identification
// calling functions will be in main.cpp (aside from error handling)
// the current code does not handle hexadecimal

\"                              {
                                    BEGIN(STRING_MODE);
                                    buf_ptr = 0;
                                }

<STRING_MODE>\"                      {
                                    BEGIN(INITIAL);
                                    string_buf[buf_ptr] = '\0';
                                    return STRING;
                                }

<STRING_MODE>\\[\\\"nrt0]            {
                                    string_buf[buf_ptr++] = yytext[0];
                                     string_buf[buf_ptr++] = yytext[1];
                                } // valid basic escapes

<STRING_MODE>\\x(09|0[aA]|0[dD]|[2-6][0-9a-fA-F]|7[0-9a-eA-E])   {
                                                                for(int i = 0; i < yyleng; i++){
                                                                    string_buf[buf_ptr++] = yytext[i];
                                                                }
                                                            } // valid hex escapes

<STRING_MODE>\\x[0-9a-fA-F]{2}       {
                                    output::errorUndefinedEscape(yytext + 1);
                                    //exit(1);
                                } //invalid hex escapes

<STRING_MODE>\\x[^\"\n\r]{0,2}       {
                                    output::errorUndefinedEscape(yytext + 1);
                                    //exit(1);
                                } //malformed hex escapes

<STRING_MODE>\\[^\n\r]               {
                                    output::errorUndefinedEscape(yytext + 1);
                                    //exit(1);
                                } // any other invalid escapes

<STRING_MODE>\\?(\r\n|\r|\n)         {
                                    output::errorUnclosedString();
                                    //exit(1);
                                } //string terminated early

<STRING_MODE><<EOF>>                 {
                                    output::errorUnclosedString();
                                    //exit(1);
                                } //string terminated early

<STRING_MODE>\\                      {
                                    output::errorUnclosedString();
                                    //exit(1);
                                } //string terminated early

<STRING_MODE>([\x20-\x21\x23-\x5B\x5D-\x7E\t])+  {
                                                for(int i = 0; i < yyleng; i++) {
                                                    string_buf[buf_ptr++] = yytext[i];
                                                }
                                            } //valid normal characters

<STRING_MODE>.                       {
                                    output::errorUnknownChar(yytext[0]);
                                    //exit(1);
                                }

{whitespace}+                   {} //do nothing since yylineno increases automatically
.                               {
                                    output::errorUnknownChar(yytext[0]);
                                    //exit(1);
                                }

%%
// User code section

