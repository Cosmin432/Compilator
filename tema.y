%{
    #include <iostream>
    #include <string>
    #include "tema.tab.h"

    int yylex(void);
    void yyerror(const char *s);
    extern int yylineno;
    extern FILE* yyin;

    std::string format_number(double num) {
    if (num == (int)num) {
        return std::to_string((int)num); 
    }
    return std::to_string(num); 
    }

    template <typename T>
    void print(const T& value) {
        std::cout << value << std::endl;
    }

    template <>
    void print(const bool& value) {
        std::cout << (value ? "true" : "false") << std::endl;
    }

    enum Section { CLASSES, GLOBAL_VARS, MAINF };
    Section current_section = CLASSES;
%}

%union {
    int int_nr;   
    float float_nr;
    double num;   
    std::string *name;    
    int dim;       
    int rows, cols; 
    bool ok;        
    std::string *prog;
}

%token <int_nr> INT_NR
%token <float_nr> FLOAT_NR
%token <name> IDENTIFIER
%token <dim> ARRAY
%token <name> MATRIX
%type <prog> program statements variable_declarations variable_declaration statement class_declaration global_variables
%token PRINT MAIN INT FLOAT CLASS IF ELSE WHILE VOID TRUE FALSE TYPEOF START STOP
%token INC DECR PLUS MINUS MULT DIV GEQ LEQ EQ NEQ ASSIGN LOW GRT NOT AND OR
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON LSQUARE RSQUARE COLON POINT

%start program

%type <name> type
%type <num> expression
%type <ok> boolean
%left PLUS MINUS    
%left MULT DIV    
%left AND OR     
%left EQ NEQ    
%right ASSIGN      

%%

program:
    class_declarations global_variables main_function
    ;

class_declarations:
    class_declaration
    | class_declarations class_declaration
    |
    ;

class_declaration:
    CLASS IDENTIFIER LBRACE variable_declarations RBRACE { 
        if (current_section != CLASSES) {
            yyerror("Classes must be declared first!");
            YYABORT;
        }        
        $$ = new std::string("Class declaration: " + *$2 + " {\n" + *$4 + "\n}"); delete $2; delete $4; }  
    ;

global_variables:
    variable_declarations { 
        if (current_section != GLOBAL_VARS && current_section != CLASSES) {
            yyerror("Global variables must be declared after classes and before functions.");
            YYABORT;
        }
        current_section = GLOBAL_VARS;
        $$ = $1; 
    }
    | 
    ;

/*function_definitions:
    function_definition
    | function_definitions function_definition
    |
    ;

function_definition:
    type IDENTIFIER LPAREN parameters RPAREN LBRACE statements RBRACE { 
        if (current_section != FUNCTIONS && current_section != GLOBAL_VARS) {
            yyerror("Functions must be declared after global variables.");
            YYABORT;
        }
        // Cod pentru definirea funcției
    }
    ;*/

main_function:
    VOID MAIN LPAREN RPAREN LBRACE statements RBRACE { 
        if (current_section != GLOBAL_VARS) {
            yyerror("Main function must be declared last.");
            YYABORT;
        }
        // Cod pentru funcția principală
    }
    ;

statements:
    statement { $$ = $1; }
    | variable_declarations { $$ = $1; }
    | statements statement { $$ = new std::string(*$1 + "\n" + *$2); delete $1; delete $2; }
    | statements variable_declarations { $$ = new std::string(*$1 + "\n" + *$2); delete $1; delete $2; }
    ;

variable_declarations:
    variable_declaration { $$ = $1; }  
    | variable_declarations variable_declaration { $$ = new std::string(*$1 + "\n" + *$2); delete $1; delete $2; }
    ;

variable_declaration:
    type IDENTIFIER SEMICOLON { $$ = new std::string("Declaration: " + *$1 + " " + *$2 + ";"); delete $1; delete $2; }
    | type ARRAY SEMICOLON { $$ = new std::string("Declaration: array of type " + *$1 + ";"); delete $1; }
    | type MATRIX SEMICOLON { $$ = new std::string("Declaration: matrix of type " + *$1 + ";"); delete $1; }
    | type IDENTIFIER ASSIGN expression SEMICOLON { $$ = new std::string("Declaration: " + *$1 + " " + *$2 + " = " + format_number($4) + ";"); delete $1; delete $2; }
    ;

statement:
    IF boolean COLON START statements STOP { $$ = new std::string("if (" + std::string($2 ? "true" : "false") + ") {\n" + *$5 + "\n}"); delete $5; }
    | WHILE boolean COLON START statements STOP { $$ = new std::string("while (" + std::string($2 ? "true" : "false") + ") {\n" + *$5 + "\n}"); delete $5; }
    | IDENTIFIER ASSIGN expression SEMICOLON { $$ = new std::string("Assignment: " + *$1 + " = " + format_number($3)); delete $1; }
    | PRINT expression SEMICOLON { 
        print($2); 
        $$ = new std::string("print(" + format_number($2) + ");");
    }    
    | PRINT boolean SEMICOLON { 
        print($2); 
        $$ = new std::string("print(" + format_number($2) + ");");
    }
    ;

type:
    INT { $$ = new std::string("int"); }    
    | FLOAT { $$ = new std::string("float"); }
    ;

expression:
    INT_NR { $$ = (double) $1; }
    | FLOAT_NR { $$ = (double) $1; }
    | IDENTIFIER { $$ = 0; }
    | IDENTIFIER LSQUARE INT_NR RSQUARE { $$ = 0;  }
    | IDENTIFIER LSQUARE INT_NR RSQUARE LSQUARE INT_NR RSQUARE { $$ = 0;}
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
