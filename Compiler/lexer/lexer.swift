//
//  File.swift
//  Compiler
//
//  Created by Alex on 14/11/2023.
//

import Foundation

typealias LexerCharacterResult = (state: LexerState, token: Token?, lexeme: String)

enum LexerState {
    case None, IntegerLiteral, StringLiteral, CharacterLiteral, Operator, Identifier
}

private func lexCharacterInNone(_ char: Character, withLexeme lexeme: String) -> LexerCharacterResult {
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

/*
 * The 'lexeme' does include prefixes and suffixes (e.g. 0x21345 or 123u) and underscores.
 */
private func lexCharacterInInteger(_ char: Character, withLexeme lexeme: String) throws -> LexerCharacterResult {
    if (lexeme == "0" && char.isLetter) {
        if (char == "X") {
            throw LexerException.uppercaseIntegerPrefix("Hexadecimal literals must start with '0x', not '0X'")
        } else if (char == "O") {
            throw LexerException.uppercaseIntegerPrefix("Octal literals must start with '0o', not '0O'")
        } else if (char == "B") {
            throw LexerException.uppercaseIntegerPrefix("Binary literals must start with '0b', not '0B'")
        } else if (char != "x" && char != "o" && char != "b") {
            throw LexerException.invalidIntegerPrefix("Invalid integer literal prefix '0\(char)'")
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
    let retriedResult = try lexCharacter(char, atState: LexerState.None, withLexeme: "")
    assert(retriedResult.token == nil)
    return (retriedResult.state, token, retriedResult.lexeme)
    
}

/*
 * The 'lexeme' does not include quotes, but will include backslashes. When converting to a token,
 * the backslashes and the following character get replaced with the actual escaped character.
 */
private func lexCharacterInCharacter(_ char: Character, withLexeme lexeme: String) throws -> LexerCharacterResult {
    if lexeme.count == 0 || (lexeme.count == 1 && lexeme == "\\") {
        /*
         * Continue the character literal if it is the first character, or comes after
         * an initial backslash.
         */
        return (LexerState.CharacterLiteral, nil, lexeme + String(char))
        
    } else if char == "\'" && ((lexeme.count == 1) || (lexeme.count == 2 && lexeme.hasPrefix("\\"))) {
        /*
         * Finish the character literal on its end quote, as long it appears in the right position.
         */
        return (LexerState.None, try CharacterLiteralToken(potentiallyBackslashedCharacter: lexeme), "")

    } else {
        /*
         * If we got to here, the literal is invalid.
         */
        throw LexerException.invalidCharacterLiteral("Character literal too long.")
    }
}

private func isStringInEscapedMode(_ str: String) -> Bool {
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
private func lexCharacterInString(_ char: Character, withLexeme lexeme: String) throws -> LexerCharacterResult {
    if char == "\"" && !isStringInEscapedMode(lexeme) {
        return (LexerState.None, try StringLiteralToken(potentiallyBackslashedString: lexeme), lexeme + String(char))
    }
    
    return (LexerState.StringLiteral, nil, lexeme + String(char))
}

private func lexCharacterInOperator(_ char: Character, withLexeme lexeme: String) throws -> LexerCharacterResult {
    guard OperatorToken.isStringValidStartOfToken(str: lexeme) else {
        throw LexerException.invalidOperatorException("Operator beginning with \(lexeme) is invalid.")
    }
    
    let newLexeme = lexeme + String(char)
    
    if OperatorToken.isStringATerminalToken(str: newLexeme) {
        return (LexerState.None, OperatorToken(str: newLexeme), "")
    }
    
    if !OperatorToken.isStringValidStartOfToken(str: newLexeme) {
        guard OperatorToken.isStringAValidToken(str: lexeme) else {
            throw LexerException.invalidOperatorException("Operator beginning with \(lexeme) is invalid.")
        }
        return (LexerState.None, OperatorToken(str: lexeme), "")
    }
    
    return (LexerState.Operator, nil, newLexeme)
}

private func lexCharacterInIdentifier(_ char: Character, withLexeme lexeme: String) throws -> LexerCharacterResult {
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
    
    let retriedResult = try lexCharacter(char, atState: LexerState.None, withLexeme: "")
    assert(retriedResult.token == nil)
    return (retriedResult.state, token, retriedResult.lexeme)
}

private func lexCharacter(_ char: Character, atState state: LexerState, withLexeme lexeme: String) throws -> LexerCharacterResult {
    return switch state {
        case .None:             lexCharacterInNone(char, withLexeme: lexeme)
        case .IntegerLiteral:   try lexCharacterInInteger(char, withLexeme: lexeme)
        case .CharacterLiteral: try lexCharacterInCharacter(char, withLexeme: lexeme)
        case .StringLiteral:    try lexCharacterInString(char, withLexeme: lexeme)
        case .Operator:         try lexCharacterInOperator(char, withLexeme: lexeme)
        case .Identifier:       try lexCharacterInIdentifier(char, withLexeme: lexeme)
    }
}

func lex(str: String) throws -> [Token] {
    var tokens: [Token] = []
    var state = LexerState.None
    var lexeme = ""
    
    /*
     * We add a whitespace character to the end so it can finsh off any token that it is
     * currently in when we hit the end of the file.
     */
    for char in str + " " {
        let result = try lexCharacter(char, atState: state, withLexeme: lexeme)
        state = result.state
        lexeme = result.lexeme
        if let token = result.token {
            tokens.append(token)
        }
    }
    
    return tokens
}


func unitTestDemo() -> Int {
    return 5
}
