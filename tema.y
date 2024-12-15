%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "tema.tab.h"

    int yylex(void);
    void yyerror(const char *s);
    extern int yylineno;

%}


%union {
    int int_nr;     // pentru numere întregi
    float float_nr; // pentru numere float
    double num;     // pentru expresii, de tip comun
    char *name;     // pentru identificatori
    int dim;        // pentru dimensiuni array
    int rows, cols; // pentru dimensiuni matrici
    char* str;
}

%token <int_nr>INT_NR
%token <float_nr>FLOAT_NR
%token <name>IDENTIFIER
%token <dim>ARRAY
%token <name>MATRIX
%token INT FLOAT CLASS IF ELSE WHILE VOID TRUE FALSE TYPEOF START STOP
%token INC DECR PLUS MINUS MULT DIV GEQ LEQ EQ NEQ ASSIGN LOW GRT NOT AND OR
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON LSQUARE RSQUARE COLON POINT

%start program

%type <str> type
%type <num>expression
%left PLUS MINUS      // operatori cu prioritate mică
%left MULT DIV        // operatori cu prioritate mai mare
%left AND OR          // operatori logici
%left EQ NEQ          // operatori de comparare
%right ASSIGN         // operator de asignare

%%

program:
    statements
    ;

statements:
    statement
    | statements statement
    ;

statement:
    type IDENTIFIER SEMICOLON
    | type ARRAY SEMICOLON
    | type MATRIX SEMICOLON
    | CLASS IDENTIFIER LBRACE statements RBRACE
    | IF LPAREN expression RPAREN statement
    | WHILE LPAREN expression RPAREN statement
    | IDENTIFIER ASSIGN expression SEMICOLON
    ;

type:
    INT { $$ = strdup("int"); }    
    | FLOAT { $$ = strdup("float"); }
    ;

expression:
      INT_NR { $$ = (double) $1; }
    | FLOAT_NR { $$ = (double) $1; }
    | IDENTIFIER { $$ = 0; /* Poți adăuga logică pentru identificatori */ }
    | IDENTIFIER LSQUARE INT_NR RSQUARE { $$ = 0; /* Logică pentru array-uri */ }
    | IDENTIFIER LSQUARE INT_NR RSQUARE LSQUARE INT_NR RSQUARE { $$ = 0; /* Logică pentru matrici */ }
    | expression PLUS expression { $$ = $1 + $3; }
    | expression MINUS expression { $$ = $1 - $3; }
    | expression MULT expression { $$ = $1 * $3; }
    | expression DIV expression { $$ = $1 / $3; }
    | expression LOW expression { $$ = $1 < $3; }
    | expression GRT expression { $$ = $1 > $3; }
    | expression GEQ expression { $$ = $1 >= $3; }
    | expression LEQ expression { $$ = $1 <= $3; }
    | expression EQ expression { $$ = $1 == $3; }
    | expression NEQ expression { $$ = $1 != $3; }
    ;


%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s at line %d\n", s, yylineno);
}


int main() {
    yyparse();
    return 0;
}
