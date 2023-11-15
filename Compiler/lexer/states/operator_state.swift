//
//  operator.swift
//  Compiler
//
//  Created by Alex on 15/11/2023.
//

import Foundation

func lexCharacterInOperator(_ char: Character, withLexeme lexeme: String, atPosition pos: LexerPosition) throws -> LexerCharacterResult {
    guard OperatorToken.isStringValidStartOfToken(str: lexeme) else {
        throw LexerException.invalidOperatorException(reason: "Operator is invalid.")
    }
    
    let newLexeme = lexeme + String(char)
    
    if OperatorToken.isStringATerminalToken(str: newLexeme) {
        return (LexerState.None, OperatorToken(str: newLexeme), "")
    }
    
    if !OperatorToken.isStringValidStartOfToken(str: newLexeme) {
        guard OperatorToken.isStringAValidToken(str: lexeme) else {
            throw LexerException.invalidOperatorException(reason: "Operator is invalid.")
        }
        return (LexerState.None, OperatorToken(str: lexeme), "")
    }
    
    return (LexerState.Operator, nil, newLexeme)
}
