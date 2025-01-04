%{
    #include <iostream>
    #include <string>
    #include <fstream>
    #include <sstream>
    #include "tema.tab.h"
    #include "symtable.h" 

    extern SymTable* currentScope; 
    int yylex(void);
    void yyerror(const char *s);
    extern int yylineno;
    extern FILE* yyin;
    std::vector<SymTable*> scope;

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
    std::string *str_val;
    char char_val;
}

%token <int_nr> INT_NR_NEG
%token <int_nr> INT_NR_POZ
%token <float_nr> FLOAT_NR
%token <str_val> STRING_LITERAL
%token <char_val> CHAR_LITERAL
%token <name> IDENTIFIER
%type <prog> program statements variable_declarations variable_declaration statement main_scope name_scope class_declaration function_definition class_declarations function_definitions main_function fuction_call class_inside class_insides parameter parameters
%token PRINT MAIN INT FLOAT CLASS IF ELSE WHILE VOID TRUE FALSE TYPEOF START STOP
%token FOR BOOL CHAR STRING INC DECR PLUS MINUS MULT DIV GEQ LEQ EQ NEQ ASSIGN LOW GRT NOT AND OR
%token COMMA LPAREN RPAREN LBRACE RBRACE SEMICOLON LSQUARE RSQUARE COLON POINT

%start program

%type <name> type
%type <num> expression
%type <ok> boolean
%left PLUS MINUS    
%left MULT DIV  
%left NOT    
%left OR AND    
%left EQ NEQ    
%right ASSIGN      

%%

program:
    class_declarations variable_declarations function_definitions main_function {
        $$ = new std::string(*$1 + "\n" + *$2 + "\n" + *$3 + "\n" + *$4);
        delete $1; delete $2; delete $3; delete $4;
    }
    | class_declarations variable_declarations main_function
    | class_declarations function_definitions main_function
    | variable_declarations function_definitions main_function
    | function_definitions main_function
    | class_declarations main_function
    | variable_declarations main_function
    | main_function
    ;

class_declarations:
    class_declaration
    | class_declarations class_declaration
    ;

class_declaration:
    CLASS name_scope LBRACE class_insides RBRACE {   
        currentScope = currentScope->getParent();  
        currentScope->addClass(*$2);    
        $$ = new std::string("Class declaration: " + *$2 ); delete $2;  }  
    | CLASS name_scope LBRACE RBRACE { 
        currentScope = currentScope->getParent();    
        $$ = new std::string("Class declaration: " + *$2 ); delete $2;  }  
    ;
name_scope:
    IDENTIFIER {
        auto previousScope = currentScope;
        $$ = new std::string(*$1);
        currentScope = new SymTable(*$$, previousScope); 
        scope.push_back(currentScope); 
        delete $1;   
    }
    ;

class_insides:
    class_inside
    | class_insides class_inside
    ;

class_inside:
    variable_declaration
    | function_definition 
    ;

function_definitions:
    function_definition
    | function_definitions function_definition
    ;

function_definition:
    type name_scope LPAREN RPAREN LBRACE statements RBRACE { 
        currentScope = currentScope->getParent(); 
        if(currentScope->getScopeName() == "global")
            currentScope->addFunction(*$2, *$1, {}, {});
        else
            currentScope->addFunction(*$2, *$1, {}, currentScope->getScopeName());
        $$ = new std::string("Function declaration: " + *$2 + " {\n" + *$6 + "\n}"); delete $2; delete $6, delete $1; 
    }
    | type name_scope LPAREN parameters RPAREN LBRACE statements RBRACE { 
        std::vector<std::string> result;
        std::stringstream ss(*$4);
        std::string segment;

        while (std::getline(ss, segment, ',')) {
            std::stringstream wordStream(segment);
            std::string firstWord;

            wordStream >> firstWord;
            result.push_back(firstWord);
        }
        currentScope = currentScope->getParent(); 
        if(currentScope->getScopeName() == "global")
            currentScope->addFunction(*$2, *$1, result, {});
        else
            currentScope->addFunction(*$2, *$1, result, currentScope->getScopeName());
        $$ = new std::string("Function declaration: " + *$2 + " {\n" + *$7 + "\n}"); delete $2; delete $7; delete $4;
    }
    ;

parameters:
    parameter
    | parameters COMMA parameter { $$ = new std::string(*$1 + "," + *$3); delete $1; delete $3;}
    ;

parameter:
    type IDENTIFIER { 
        currentScope->addVariable(*$1, *$2, {});
        $$ = new std::string(*$1 + " " + *$2); delete $1; delete $2; }
    | type IDENTIFIER LSQUARE INT_NR_POZ RSQUARE { 
        $$ = new std::string(*$1 + "[" + format_number($4) + "]");
        currentScope->addVariable(*$$, *$2, {});
        $$ = new std::string(*$1 + "[" + format_number($4) + "] " + *$2); delete $1; delete $2; }
    | type IDENTIFIER LSQUARE INT_NR_POZ RSQUARE LSQUARE INT_NR_POZ RSQUARE { 
        $$ = new std::string(*$1 + "[" + format_number($4) + "][" + format_number($7) + "]");
        currentScope->addVariable(*$$, *$2, {});
        $$ = new std::string(*$1 + "[" + format_number($4) + "][" + format_number($7) + "] " + *$2); delete $1; delete $2; }
    | IDENTIFIER IDENTIFIER { 
        currentScope->addVariable(*$1, *$2);
        $$ = new std::string(*$1 + " " + *$2); delete $1; delete $2; }
    ;

main_function:
    VOID main_scope LPAREN RPAREN LBRACE statements RBRACE {
        $$ = new std::string("Main function {\n" + *$6 + "\n}");
        delete $6;
    }
    ;

main_scope:
    MAIN {
        auto previousScope = currentScope;
        currentScope = new SymTable("main", previousScope); 
        scope.push_back(currentScope); 
    }
    ;

statements:
    statement { $$ = $1; }
    | statements statement { $$ = new std::string(*$1 + "\n" + *$2); delete $1; delete $2; }
    ;

variable_declarations:
    variable_declaration { $$ = $1; }  
    | variable_declarations variable_declaration { $$ = new std::string(*$1 + "\n" + *$2); delete $1; delete $2; }
    ;

variable_declaration:
    type IDENTIFIER SEMICOLON { 
        currentScope->addVariable(*$1, *$2, {});
        $$ = new std::string("Declaration: " + *$1 + " " + *$2 + ";"); delete $1; delete $2; }
    | type IDENTIFIER LSQUARE INT_NR_POZ RSQUARE SEMICOLON { 
        $$ = new std::string(*$1 + "[" + format_number($4) + "]");
        currentScope->addVariable(*$$, *$2, {});
        delete $1; delete $2; }
    | type IDENTIFIER LSQUARE INT_NR_POZ RSQUARE LSQUARE INT_NR_POZ RSQUARE SEMICOLON {
        $$ = new std::string(*$1 + "[" + format_number($4) + "][" + format_number($7) + "]");
        currentScope->addVariable(*$$, *$2, {});
        delete $1; delete $2; }
    | type IDENTIFIER ASSIGN expression SEMICOLON { 
        currentScope->addVariable(*$1, *$2, format_number($4));
        $$ = new std::string("Declaration: " + *$1 + " " + *$2 + " = " + format_number($4) + ";"); delete $1; delete $2; }
    | type IDENTIFIER ASSIGN STRING_LITERAL SEMICOLON { 
        currentScope->addVariable(*$1, *$2, *$4);
        $$ = new std::string("Declaration: " + *$1 + " " + *$2 + " = " + *$4 + ";"); delete $1; delete $2; delete $4;}
    | IDENTIFIER IDENTIFIER SEMICOLON { 
        currentScope->addVariable(*$1, *$2);
        $$ = new std::string("Declaration: " + *$1 + " " + *$2 + ";"); delete $1; delete $2; }
    ;

fuction_call:
    IDENTIFIER LPAREN parameters_call RPAREN  { $$ = new std::string(*$1); delete $1; }
    | IDENTIFIER LPAREN RPAREN { $$ = new std::string(*$1); delete $1; }
    | IDENTIFIER POINT fuction_call { $$ = new std::string(*$3); delete $3; }
    ;

statement:
    IF boolean COLON block_scope statements STOP { 
        currentScope = currentScope->getParent();  
        $$ = new std::string("if (" + std::string($2 ? "true" : "false") + ") {\n" + *$5 + "\n}"); delete $5; }
    | WHILE boolean COLON block_scope statements STOP { 
        currentScope = currentScope->getParent();  
        $$ = new std::string("while (" + std::string($2 ? "true" : "false") + ") {\n" + *$5 + "\n}"); delete $5; }
    | FOR IDENTIFIER ASSIGN expression SEMICOLON boolean SEMICOLON IDENTIFIER ASSIGN expression block_scope statements STOP { 
        currentScope = currentScope->getParent();  
        $$ = new std::string("for (" + *$2 + " = " + format_number($4) + "; " + std::string($6 ? "true" : "false") + "; " + *$8 + " = " + format_number($10) + ") {\n" + *$12 + "\n}"); delete $12; }
    | IDENTIFIER ASSIGN expression SEMICOLON { $$ = new std::string("Assignment: " + *$1 + " = " + format_number($3)); delete $1; }
    | IDENTIFIER ASSIGN STRING_LITERAL SEMICOLON { $$ = new std::string("Assignment: " + *$1 + " = " + *$3); delete $1; delete $3;}
    | PRINT LPAREN expression RPAREN SEMICOLON { 
        print($3); 
        $$ = new std::string("print(" + format_number($3) + ");");
    }    
    | PRINT LPAREN STRING_LITERAL RPAREN SEMICOLON { 
        print(*$3); 
        $$ = new std::string("print(" + *$3 + ");");
        delete $3;
    }    
    | PRINT LPAREN boolean RPAREN SEMICOLON { 
        print($3); 
        $$ = new std::string("print(" + format_number($3) + ");");
    }    
    | PRINT LPAREN fuction_call RPAREN SEMICOLON { 
        print(*$3); 
        $$ = new std::string("print(" + *$3 + ");");
        delete $3;
    }
    | TYPEOF LPAREN expression RPAREN SEMICOLON {
        print("expression");
        $$ = new std::string("typeof(" + format_number($3) + ");");
    }    
    | TYPEOF LPAREN STRING_LITERAL RPAREN SEMICOLON {
        print("string");
        $$ = new std::string("typeof(" + *$3 + ");");
        delete $3;
    }
    | TYPEOF LPAREN boolean RPAREN SEMICOLON {
        print("bool");
        $$ = new std::string("typeof(" + format_number($3) + ");");
    }
    | variable_declaration { $$ = $1; }
    | fuction_call SEMICOLON { $$ = $1; }
    | IDENTIFIER POINT IDENTIFIER ASSIGN expression SEMICOLON { $$ = new std::string("Assignment: " + *$3 + " = " + format_number($5)); delete $3; }
    | IDENTIFIER POINT IDENTIFIER ASSIGN STRING_LITERAL SEMICOLON { $$ = new std::string("Assignment: " + *$3 + " = " + *$5); delete $3; delete $5;}
    ;

block_scope:
    START {
        auto previousScope = currentScope;
        currentScope = new SymTable("block", previousScope); 
        scope.push_back(currentScope); 
    }
    ;

parameters_call:
    parameter_call
    | parameters_call COMMA parameter_call
    ;

parameter_call:
    expression
    | fuction_call
    | STRING_LITERAL
    ;

type:
    INT { $$ = new std::string("int"); }    
    | FLOAT { $$ = new std::string("float"); }
    | CHAR { $$ = new std::string("char"); }
    | STRING { $$ = new std::string("string"); }
    | BOOL { $$ = new std::string("bool"); }
    ;

expression:
    INT_NR_NEG { $$ = (double) $1; }
    | INT_NR_POZ { $$ = (double) $1; }
    | FLOAT_NR { $$ = (double) $1; }
    | CHAR_LITERAL { $$ = (double) $1; }
    | IDENTIFIER { $$ = 0; }
    | IDENTIFIER LSQUARE INT_NR_POZ RSQUARE { $$ = 0;  }
    | IDENTIFIER LSQUARE INT_NR_POZ RSQUARE LSQUARE INT_NR_POZ RSQUARE { $$ = 0;}
    | IDENTIFIER POINT IDENTIFIER { $$ = 0; }
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
    currentScope = new SymTable("global", {}); 
    scope.push_back(currentScope);
    yyparse();
    std::ofstream outFile("symtable.txt");
    for(const auto& current : scope)
        if(current->getScopeName() != "block")
            current->print(outFile);
    outFile.close();
    return 0;
}