#include "symtable.h"
#include "astnode.h"
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

void SymTable::addExpr(const std::string& val, const std::string& type) {

    expr_type.push_back(expr(val, type));
}

void SymTable::addNode(ASTValue val, std::string rez) {

    ast.push_back({new ASTNode(val), rez});
}

void SymTable::addNode(std::string id, int ok, std::string rez) {
    
    ast.push_back({new ASTNode(id, ok), rez});
}

void SymTable::addNode(std::string op, ASTNode* left, ASTNode* right, std::string rez) {

    ast.push_back({new ASTNode(op, left, right), rez});
}

ASTNode* SymTable::findnode(std::string rez) {

    int lastIndex = -1;          // Indexul ultimei apariții (inițial -1)

    // Parcurgem vectorul de la sfârșit la început
    for (int i = ast.size() - 1; i >= 0; --i) {
        if (ast[i].second == rez) {
            lastIndex = i;
            break; // Găsit ultima apariție, ieșim din buclă
        }
    }  
    return ast[lastIndex].first;  
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

    if (!expr_type.empty()) {
        out << "Expr:\n";
        for (const auto& variable : expr_type) {
            out << "  " << std::setw(15) << variable.type << " " 
                << std::setw(15) << variable.val;
            out << "\n";
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

std::string SymTable::getVariableValue(const std::string& name) const {
    for (const auto& var : variables) {
        if (var.name == name) {
            return var.value;
        }
    }
    if (parent) {
        return parent->getVariableValue(name); 
    }    
    return {};
}
    
std::string SymTable::getVariableType(const std::string& name) const {
    for (const auto& var : variables) {
        if (var.name == name) {
            return var.type;
        }
    }
    if (parent) {
        return parent->getVariableType(name); 
    } 
    return {};
}

void SymTable::changeVariableValue(const std::string& name, std::string& val) {

    int ok = 0;
    for (Variable& var : variables) {
        if (var.name == name) {
            ok = 1;
            var.value = val;
        }
    }
    if (parent && ok == 0) {
        parent->changeVariableValue(name, val); 
    }    
}

std::string SymTable::getExprType(const std::string& name) const {
    for (const auto& exp : expr_type) {
        if (exp.val == name) {
            return exp.type;
        }
    }
    if (parent) {
        return parent->getVariableType(name); 
    } 
    return {};    
}

std::string SymTable::getFunctionType(const std::string& name) const {
    for (const auto& func : functions) {
        if (func.name == name) {
            return func.returnType; // Funcția a fost găsită
        }
    }

    return {}; // Funcția nu a fost găsită în niciun scop    
}

std::string SymTable::getFunctionParameters(const std::string& name) const
{
    for (const auto& func : functions) {
        if (func.name == name) {
            std::string p = "";
            for(const auto& param : func.params)
                p = p + param + ", ";
            p.resize(p.length() - 2);
            return p;
        }
    }

    return {}; // Funcția nu a fost găsită în niciun scop       
}
