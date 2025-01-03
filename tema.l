%{
    #include <iostream>
    #include <string>  // pentru funcții de manipulare a șirurilor
    #include "tema.tab.h"
    void yyerror(const char *s);
    extern FILE *yyin;
%}

%option noyywrap
%option yylineno

identifier [a-zA-Z][a-zA-Z0-9_]*
size [1-9][0-9]*

%%

"int" { return INT; }
"float" { return FLOAT; }
"bool" { return BOOL; }
"char" { return CHAR; }
"string" { return STRING; }
"class" { return CLASS; }
"if" { return IF; }
"else" { return ELSE; }
"while" { return WHILE; }
"for" { return FOR; }
"void" { return VOID; }
"true" { return TRUE; }
"false" { return FALSE; }
"TypeOf" { return TYPEOF; }
"begin" { return START; }  // Keep this if you need it
"end" { return STOP; }    // Keep this if you need it
"main" { return MAIN; }
"print" { return PRINT; }
"typeof" { return TYPEOF; }

\"[^\"]*\" { 
    yylval.str_val = new std::string(yytext); 
    return STRING_LITERAL; 
} 

\'(.)\' { 
    yylval.char_val = yytext[1]; 
    return CHAR_LITERAL; 
} 

(-?[1-9][0-9]*)|0 { 
    yylval.int_nr = atoi(yytext); 
    return INT_NR; 
}

-?([1-9][0-9]*|0)\.[0-9]+ { 
    yylval.float_nr = atof(yytext); 
    return FLOAT_NR; 
}

{identifier}"["{size}"]""["{size}"]" {
    char id[256];
    sscanf(yytext, "%s[%d][%d]", id, &yylval.rows, &yylval.cols);
    yylval.name = new std::string(id);  // Folosește std::string în loc de strdup
    return MATRIX;
}

{identifier}"["{size}"]" {
    char id[256];
    sscanf(yytext, "%s[%d]", id, &yylval.dim);
    yylval.name = new std::string(id);  // Folosește std::string în loc de strdup
    return ARRAY;
}

{identifier} { 
    yylval.name = new std::string(yytext);  // Folosește std::string în loc de strdup
    return IDENTIFIER; 
}

"++" { return INC; }
"--" { return DECR; }
"+" { return PLUS; }
"-" { return MINUS; }
"*" { return MULT; }
"/" { return DIV; }
">=" { return GEQ; }
"<=" { return LEQ; }
"==" { return EQ; }
"!=" { return NEQ; }
"=" { return ASSIGN; }
"<" { return LOW; }
">" { return GRT; }
"!" { return NOT; }
"&&" { return AND; }
"||" { return OR; }
"(" { return LPAREN; }
")" { return RPAREN; }
"{" { return LBRACE; }
"}" { return RBRACE; }
";" { return SEMICOLON; }
"[" { return LSQUARE; }
"]" { return RSQUARE; }
":" { return COLON; }
"." { return POINT; }
"," { return COMMA; }

[ \t] ;  // Skip whitespace

\n { yylineno++; }

. { yyerror("Invalid character"); }

%%
