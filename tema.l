%{
    #include "tema.tab.h"
    #include <stdio.h>
    #include <string.h>
    void yyerror(const char *s);
%}

%option noyywrap
%option yylineno

identifier [a-zA-Z][a-zA-Z0-9_]*
size [1-9][0-9]*

%%


"int" { printf("Found token: INT\n"); return INT; }
"float" { return FLOAT; }
"class" { return CLASS; }
"if" { return IF; }
"else" { return ELSE; }
"while" { return WHILE; }
"void" { return VOID; }
"true" { return TRUE; }
"false" { return FALSE; }
"TypeOf" { return TYPEOF; }
"begin" { return START; }  // Keep this if you need it
"end" { return STOP; }    // Keep this if you need it

(-?[1-9][0-9]*)|0 { 
    yylval.int_nr = atoi(yytext); 
    return INT_NR; 
}

-?([1-9][0-9]*|0)\.[0-9]+ { 
    yylval.float_nr = atof(yytext); 
    return FLOAT_NR; 
}

{identifier}"["{size}"]""["{size}"]" {
    printf("Found token: MATRIX\n");
    char id[256];
    sscanf(yytext, "%s[%d][%d]", id, &yylval.rows, &yylval.cols);
    yylval.name = strdup(id);
    return MATRIX;
}

{identifier}"["{size}"]" {
    printf("Found token: ARRAY\n");
    char id[256];
    sscanf(yytext, "%s[%d]", id, &yylval.dim);
    yylval.name = strdup(id);
    return ARRAY;
}

{identifier} { 
    printf("Found token: IDENTIFIER\n");
    yylval.name = strdup(yytext); 
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

[ \t] ;  // Skip whitespace

\n { yylineno++; }

. { yyerror("Invalid character"); }


%%
