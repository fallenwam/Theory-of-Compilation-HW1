#include "tokens.hpp"
#include "output.hpp"

extern char string_buf[];

int main() {
    enum tokentype token;

    while ((token = static_cast<tokentype>(yylex()))) {

        if (token == STRING) { //TODO: THIS IS INCORRECT. NEED TO PROPERLY PARSE THE STRING.
            /* string_buf contains parenthesis at start and end which need to be ignored and not printed.
             * need to replace occurrences of hexadecimals to ASCII. hexadecimals in the string
             * are always in the form \xDD where D is in [0-9] or [a-f] or [A-F].
             * Assume every hexadecimal will be a valid printable character as our scanner
             * does the filtering already. to find occurrences of \ look for '\\' in string_buf[i].
             * valid escapes are \r, \t, \n, \", \\, \0 (where \0 needs to stop the print)
             */
            output::printToken(yylineno, token, string_buf);
        }
        else {
            output::printToken(yylineno, token, yytext);
        }
    }
    return 0;
}