#pragma once

#include <memory>
#include <variant>
#include <string>
#include <stdexcept>
#include <iostream>

// Define a variant for holding node values
using ASTValue = std::variant<int, float, bool, std::string, char>;

// Forward declaration of Symbol Table
class SymTable;

class ASTNode {
public:
    // Enum to represent the type of the node
    enum class NodeType {
        Literal,      // e.g., numbers, booleans
        Identifier,   // e.g., variable names
        Operator      // e.g., '+', '*', '||'
    };

    // Constructor for literals (e.g., numbers, booleans)
    ASTNode(ASTValue val);

    // Constructor for identifiers (e.g., variable names)
    ASTNode(std::string id, int ok);

    // Constructor for operators (e.g., '+', '*', '||')
    ASTNode(std::string op, ASTNode* left, ASTNode* right = nullptr);

    // Evaluate the AST
    ASTValue evaluate(SymTable* currentScope) const;

    // Get the type of the AST (e.g., "int", "float", "bool")
    std::string getType(SymTable* currentScope) const;

private:
    NodeType type;                         // Type of the node
    std::string op;                        // Operator for operator nodes
    ASTValue value;                        // Value for literal or identifier nodes
    ASTNode* left;         // Left subtree
    ASTNode* right;        // Right subtree
};

