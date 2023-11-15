//
//  integer.swift
//  Compiler
//
//  Created by Alex on 15/11/2023.
//

import Foundation

/*
 * The 'lexeme' does include prefixes and suffixes (e.g. 0x21345 or 123u) and underscores.
 */
func lexCharacterInInteger(_ char: Character, withLexeme lexeme: String, atPosition pos: LexerPosition) throws -> LexerCharacterResult {
    if (lexeme == "0" && char.isLetter) {
        if (char == "X") {
            throw LexerException.uppercaseIntegerPrefix(reason: "Hexadecimal literals must start with '0x', not '0X'")
        } else if (char == "O") {
            throw LexerException.uppercaseIntegerPrefix(reason: "Octal literals must start with '0o', not '0O'")
        } else if (char == "B") {
            throw LexerException.uppercaseIntegerPrefix(reason: "Binary literals must start with '0b', not '0B'")
        } else if (char != "x" && char != "o" && char != "b") {
            throw LexerException.invalidIntegerPrefix(reason: "Invalid integer literal prefix '0\(char)'")
        }
    }
    

    /*
     * Allow characters for things like hex literals, suffixes (e.g. for floating point values).
     * Invalid characters will be picked up on when we try to convert it into an IntegerLiteralToken.
     */
    if char.isNumber || char.isLetter || char == "_" {
        /*
         * It continues to be an integer literal.
         */
        return (LexerState.IntegerLiteral, nil, lexeme + String(char))
    }
    
    /*
     * We now have a character that's not part of the literal, so create the token from the
     * lexeme so far, and retry this character as a new token. We need to inject this token into the
     * return value of the retry, which is okay, as it will always have a nil in that slot of the tuple.
     */
    let token = try IntegerLiteralToken(lexeme: lexeme)
    let retriedResult = try lexCharacter(char, atState: LexerState.None, withLexeme: "", atPosition: pos)
    assert(retriedResult.token == nil)
    return (retriedResult.state, token, retriedResult.lexeme)
    
}
