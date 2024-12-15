%{
    #include <iostream>
    #include <string>
    #include "tema.tab.h"

    int yylex(void);
    void yyerror(const char *s);
    extern int yylineno;
    extern FILE* yyin;
%}

%union {
    int int_nr;     // pentru numere întregi
    float float_nr; // pentru numere float
    double num;     // pentru expresii, de tip comun
    std::string *name;     // pentru identificatori
    int dim;        // pentru dimensiuni array
    int rows, cols; // pentru dimensiuni matrici
    bool ok;        // pentru valori booleene
}

%token <int_nr> INT_NR
%token <float_nr> FLOAT_NR
%token <name> IDENTIFIER
%token <dim> ARRAY
%token <name> MATRIX
%token INT FLOAT CLASS IF ELSE WHILE VOID TRUE FALSE TYPEOF START STOP
%token INC DECR PLUS MINUS MULT DIV GEQ LEQ EQ NEQ ASSIGN LOW GRT NOT AND OR
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON LSQUARE RSQUARE COLON POINT

%start program

%type <name> type
%type <num> expression
%type <ok> boolean
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
    | variable_declarations
    | statements statement
    | statements variable_declarations
    ;

variable_declarations:
    type IDENTIFIER SEMICOLON
    | type ARRAY SEMICOLON
    | type MATRIX SEMICOLON
    | type IDENTIFIER ASSIGN expression SEMICOLON
    | CLASS IDENTIFIER LBRACE statements RBRACE
    ;

statement:
    | IF boolean COLON START statements STOP
    | WHILE boolean COLON START statements STOP
    | IDENTIFIER ASSIGN expression SEMICOLON
    ;

type:
    INT { $$ = new std::string("int"); }    
    | FLOAT { $$ = new std::string("float"); }
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
    ;

boolean:   
    TRUE { $$ = true; }
    | FALSE { $$ = false; }
    | expression LOW expression { $$ = $1 < $3; }
    | expression GRT expression { $$ = $1 > $3; }
    | expression GEQ expression { $$ = $1 >= $3; }
    | expression LEQ expression { $$ = $1 <= $3; }
    | expression EQ expression { $$ = $1 == $3; }
    | expression NEQ expression { $$ = $1 != $3; }
    | boolean AND boolean { $$ = $1 && $3; }
    | boolean OR boolean { $$ = $1 || $3; }
    | NOT boolean { $$ = !$2; }
    ;

%%

void yyerror(const char *s) {
    std::cerr << "Error: " << s << " at line " << yylineno << std::endl;
}

int main(int argc, char** argv)
{
    yyin = fopen(argv[1], "r");
    yyparse();
    return 0;
}
