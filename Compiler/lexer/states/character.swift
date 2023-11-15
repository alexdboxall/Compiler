//
//  character.swift
//  Compiler
//
//  Created by Alex on 15/11/2023.
//

import Foundation

/*
 * The 'lexeme' does not include quotes, but will include backslashes. When converting to a token,
 * the backslashes and the following character get replaced with the actual escaped character.
 */
func lexCharacterInCharacter(_ char: Character, withLexeme lexeme: String, atPosition pos: LexerPosition) throws -> LexerCharacterResult {
    if lexeme.count == 0 || (lexeme.count == 1 && lexeme == "\\") {
        /*
         * Continue the character literal if it is the first character, or comes after
         * an initial backslash.
         */
        return (LexerState.CharacterLiteral, nil, lexeme + String(char))
        
    } else if char == "\'" && (lexeme.count == 1 || (lexeme.count == 2 && lexeme.hasPrefix("\\"))) {
        /*
         * Finish the character literal on its end quote, as long it appears in the right position.
         */
        return (LexerState.None, try CharacterLiteralToken(potentiallyBackslashedCharacter: lexeme), "")

    } else {
        /*
         * If we got to here, the literal is invalid.
         */
        throw LexerException.invalidCharacterLiteral(reason: "Character literal too long.", columnOffset: lexeme.count + 1)
    }
}
