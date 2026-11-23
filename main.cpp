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
            int buf_ptr = 0;
        
            while(yytext[buf_ptr] != '\0') {
                if (yytext[buf_ptr] == '\\') {
                    buf_ptr++;
                    if (yytext[buf_ptr] == 'x') {
                        // Convert hex to ASCII
                        char hex_chars[3] = { yytext[buf_ptr + 1], yytext[buf_ptr + 2], '\0' };
                        string_buf[buf_ptr] = static_cast<char>(strtol(hex_chars, nullptr, 16));
                        buf_ptr += 2; // Skip the two hex digits
                    } else {
                        // Handle other escape sequences
                        switch (yytext[buf_ptr]) {
                            case 'n': string_buf[buf_ptr] = '\n'; break;
                            case 't': string_buf[buf_ptr] = '\t'; break;
                            case 'r': string_buf[buf_ptr] = '\r'; break;
                            case '"': string_buf[buf_ptr] = '"'; break;
                            case '\\': string_buf[buf_ptr] = '\\'; break;
                            case '0': string_buf[buf_ptr] = '\0'; break; // Stop at null terminator
                            default: string_buf[buf_ptr] = yytext[buf_ptr]; break; // Unknown escape, copy as is
                        }
                    }
                } else {
                    string_buf[buf_ptr] = yytext[buf_ptr];
                }
                buf_ptr++;
            }

            output::printToken(yylineno, token, string_buf);
        }
        else {
            output::printToken(yylineno, token, yytext);
        }
    }
    return 0;
}