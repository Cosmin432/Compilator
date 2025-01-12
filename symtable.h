#ifndef SYMTABLE_H
#define SYMTABLE_H

#include <string>
#include <vector>
#include <memory>
#include <iostream>

struct Variable {
    std::string type;
    std::string name;
    std::string value;

    Variable() : type(""), name(""), value("") {}
    Variable(const std::string& type, const std::string& name, const std::string& value = "")
        : type(type), name(name), value(value) {}
};

struct Function {
    std::string name;
    std::string returnType;
    std::vector<std::string> params;
    std::string class_name;

    Function() : name(""), returnType(""), params({}), class_name("") {}
    Function(const std::string& name, const std::string& returnType, const std::vector<std::string>& params, const std::string& class_name)
        : name(name), returnType(returnType), params(params), class_name(class_name) {}
};

struct Class {
    std::string name;  

    Class() : name("") {}
    Class(const std::string& name) : name(name) {}
};

class SymTable {
private:
    std::string scopeName;                            
    SymTable* parent;                 
    std::vector<Variable> variables;                  
    std::vector<Function> functions;                  
    std::vector<Class> classes;                      

public:
    SymTable(const std::string& scopeName, SymTable* parent = nullptr)
        : scopeName(scopeName), parent(parent) {}

    void addVariable(const std::string& type, const std::string& name, const std::string& value = "");

    void addFunction(const std::string& name, const std::string& returnType, const std::vector<std::string>& params, const std::string& class_name);

    void addClass(const std::string& name);

    bool findVariable(const std::string& name) const;

    bool findFunction(const std::string& name) const;

    void print(std::ostream& out) const;

    SymTable* getParent() const { return parent; }

    std::string getScopeName() const { return scopeName; }

    void rename(std::string name) { scopeName = name; } 

    std::string getVariableValue(const std::string& name) const;
    
    std::string getVariableType(const std::string& name) const;
};
extern SymTable* currentScope;

#endif 