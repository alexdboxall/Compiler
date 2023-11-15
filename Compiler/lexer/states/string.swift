//
//  string.swift
//  Compiler
//
//  Created by Alex on 15/11/2023.
//

import Foundation

func isStringInEscapedMode(_ str: String) -> Bool {
    var escaped = false
    for char in str {
        if escaped {
            escaped = false
        } else if char == "\\" {
            escaped = true
        }
    }
    return escaped
}

/*
 * The 'lexeme' does not include quotes, but will include backslashes. When converting to a token,
 * the backslashes and the following character get replaced with the actual escaped character.
 */
func lexCharacterInString(_ char: Character, withLexeme lexeme: String, atPosition pos: LexerPosition) throws -> LexerCharacterResult {
    if char == "\"" && !isStringInEscapedMode(lexeme) {
        return (LexerState.None, try StringLiteralToken(potentiallyBackslashedString: lexeme), lexeme + String(char))
    }
    
    return (LexerState.StringLiteral, nil, lexeme + String(char))
}
