#include "tokens.hpp"
#include "output.hpp"

extern char string_buf[];

static int hexVal(char current_char) {
    if (current_char >= '0' && current_char <= '9') return current_char - '0';
    if (current_char >= 'a' && current_char <= 'f') return current_char - 'a' + 10;
    return current_char - 'A' + 10;
}

int main() {
    enum tokentype token;

    while ((token = static_cast<tokentype>(yylex()))) {

        if (token == STRING) { 
            /* 
            TODO: THIS IS INCORRECT. NEED TO PROPERLY PARSE THE STRING.
            /* string_buf contains quatation marks at start and end which need to be ignored and not printed.
             * need to replace occurrences of hexadecimals to ASCII. hexadecimals in the string
             * are always in the form \xDD where D is in [0-9] or [a-f] or [A-F].
             * Assume every hexadecimal will be a valid printable character as our scanner
             * does the filtering already. to find occurrences of \ look for '\\' in string_buf[i].
             * valid escapes are \r, \t, \n, \", \\, \0 (where \0 needs to stop the print)
             */
            int buf_ptr = 0;
            int buf_read_ptr = 0;
            int buf_write_ptr = 0;
        
            while(string_buf[buf_read_ptr] != '\0') {
                /* inside the string */

                if (string_buf[buf_read_ptr] == '\\') {
                    /* inside an escape sequence */

                    buf_read_ptr++;
                    if (string_buf[buf_read_ptr] == 'x') { 
                        /* Convert hex to ASCII */
                        int val = hexVal(string_buf[buf_read_ptr + 1]) * 16 + hexVal(string_buf[buf_read_ptr + 2]);
                        string_buf[buf_write_ptr++] = static_cast<char>(val);
        
                        buf_read_ptr += 2; 
                        /* Skip the two hex digits */

                    } else {
                        /* Handle other escape sequences */
                        if (string_buf[buf_read_ptr] == '0') {
                            /* Stop processing on null character */
                            break;

                        } else {
                            switch (string_buf[buf_read_ptr]) {
                            case 'n': string_buf[buf_write_ptr++] = '\n'; break;
                            case 'r': string_buf[buf_write_ptr++] = '\r'; break;
                            case 't': string_buf[buf_write_ptr++] = '\t'; break;
                            case '"': string_buf[buf_write_ptr++] = '"'; break;
                            case '\\': string_buf[buf_write_ptr++] = '\\'; break;
                            
                            /* default: string_buf[buf_write_ptr++] = string_buf[buf_read_ptr]; break;  */
                            /* Unknown escape, copy as is */
                            }
                        }
                        
                    }
                } else {
                    string_buf[buf_write_ptr++] = string_buf[buf_read_ptr];
                }
                buf_read_ptr++;
            }

            string_buf[buf_write_ptr] = '\0';

            output::printToken(yylineno, token, string_buf);

        }
        else {
            output::printToken(yylineno, token, yytext);
        }
    }
    return 0;
}