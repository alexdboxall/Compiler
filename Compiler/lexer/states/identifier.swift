//
//  identifier.swift
//  Compiler
//
//  Created by Alex on 15/11/2023.
//

import Foundation

func lexCharacterInIdentifier(_ char: Character, withLexeme lexeme: String, atPosition pos: LexerPosition) throws -> LexerCharacterResult {
    if char.isLetter || char.isNumber || char == "_" {
        return (LexerState.Identifier, nil, lexeme + String(char))
    }
    
    /*
     * Check if it's a keyword, or just a regular identifier.
     */
    let token: Token = if OperatorToken.isStringATerminalToken(str: lexeme) {
        OperatorToken(str: lexeme)
        
    } else {
        IdentifierToken(lexeme: lexeme)
    }
    
    let retriedResult = try lexCharacter(char, atState: LexerState.None, withLexeme: "", atPosition: pos)
    assert(retriedResult.token == nil)
    return (retriedResult.state, token, retriedResult.lexeme)
}
