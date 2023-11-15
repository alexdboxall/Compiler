//
//  none.swift
//  Compiler
//
//  Created by Alex on 15/11/2023.
//

import Foundation

func lexCharacterInNone(_ char: Character, withLexeme lexeme: String, atPosition pos: LexerPosition) -> LexerCharacterResult {
    /*
     * All of these must (obviously) return nil as the 'new token' field. The rest of the lexer
     * relies on this - it will retry characters when it hits the end of the token, and inject
     * its finished token into where the nil was.
     */
    
    if char.isNumber {
        return (LexerState.IntegerLiteral, nil, String(char))
        
    } else if char == "\"" {
        return (LexerState.StringLiteral, nil, "")
        
    } else if char == "'" {
        return (LexerState.CharacterLiteral, nil, "")
        
    } else if char.isLetter || char == "_" {
        return (LexerState.Identifier, nil, String(char))
        
    } else if char.isWhitespace {
        return (LexerState.None, nil, "")
        
    } else {
        return (LexerState.Operator, nil, String(char))
    }
}
