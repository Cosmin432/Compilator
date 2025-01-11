#include "symtable.h"
#include <iostream>
#include <iomanip>
SymTable* currentScope = nullptr;

void SymTable::addVariable(const std::string& type, const std::string& name, const std::string& value) {

    for (const auto& var : variables) {
        if (var.name == name) {
            std::cerr << "Error: Variable '" << name << "' already exists in scope '" << scopeName << "'\n";
            return;
        }
    }
    variables.push_back(Variable(type, name, value)); 
}

void SymTable::addFunction(const std::string& name, const std::string& returnType, const std::vector<std::string>& params, const std::string& class_name) {

    for (const auto& func : functions) {
        if (func.name == name) {
            std::cerr << "Error: Function '" << name << "' already exists in scope '" << scopeName << "'\n";
            return;
        }
    }
    functions.push_back(Function(name, returnType, params, class_name)); 
}

void SymTable::addClass(const std::string& name) {

    for (const auto& cls : classes) {
        if (cls.name == name) {
            std::cerr << "Error: Class '" << name << "' already exists in scope '" << scopeName << "'\n";
            return;
        }
    }
    classes.push_back(Class(name)); 
}

void SymTable::print(std::ostream& out) const {
    out << "Scope: " << scopeName << "\n";
    out << std::string(40, '-') << "\n";

    if (!variables.empty()) {
        out << "Variables:\n";
        for (const auto& variable : variables) {
            out << "  " << std::setw(15) << variable.type << " " 
                << std::setw(15) << variable.name;
            if (!variable.value.empty()) {
                out << " = " << variable.value;
            }
            out << "\n";
        }
    }

    if (!functions.empty()) {
        out << "Functions:\n";
        for (const auto& function : functions) {
            out << "  " << std::setw(15) << function.returnType << " " 
                << std::setw(15) << function.name << "(";
            for (size_t i = 0; i < function.params.size(); ++i) {
                out << function.params[i];
                if (i < function.params.size() - 1) out << ", ";
            }
            out << ")\n";
        }
    }

    if (!classes.empty()) {
        out << "Classes:\n";
        for (const auto& cls : classes) {
            out << "  " << cls.name << "\n";
        }
    }

    out << std::string(40, '-') << "\n" << "\n";
    out << "\n";
}

bool SymTable::findVariable(const std::string& name) const {
    for (const auto& var : variables) {
        if (var.name == name) {
            return true;
        }
    }
    if (parent) {
        return parent->findVariable(name); 
    }
    return false;
}
    bool SymTable::findFunction(const std::string& name) const {
    // Căutăm funcția în lista de funcții din scopul curent
    for (const auto& func : functions) {
        if (func.name == name) {
            return true; // Funcția a fost găsită
        }
    }

    return false; // Funcția nu a fost găsită în niciun scop
}


