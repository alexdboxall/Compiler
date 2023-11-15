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

struct LexerPosition {
    let lineNumber: Int
    let column: Int
    let filename: String
    
    init(lineNumber: Int, column: Int, filename: String) {
        self.lineNumber = lineNumber
        self.column = column
        self.filename = filename
    }
}

private func lexCharacterInNone(_ char: Character, withLexeme lexeme: String, atPosition pos: LexerPosition) -> LexerCharacterResult {
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
private func lexCharacterInInteger(_ char: Character, withLexeme lexeme: String, atPosition pos: LexerPosition) throws -> LexerCharacterResult {
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

/*
 * The 'lexeme' does not include quotes, but will include backslashes. When converting to a token,
 * the backslashes and the following character get replaced with the actual escaped character.
 */
private func lexCharacterInCharacter(_ char: Character, withLexeme lexeme: String, atPosition pos: LexerPosition) throws -> LexerCharacterResult {
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
private func lexCharacterInString(_ char: Character, withLexeme lexeme: String, atPosition pos: LexerPosition) throws -> LexerCharacterResult {
    if char == "\"" && !isStringInEscapedMode(lexeme) {
        return (LexerState.None, try StringLiteralToken(potentiallyBackslashedString: lexeme), lexeme + String(char))
    }
    
    return (LexerState.StringLiteral, nil, lexeme + String(char))
}

private func lexCharacterInOperator(_ char: Character, withLexeme lexeme: String, atPosition pos: LexerPosition) throws -> LexerCharacterResult {
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

private func lexCharacterInIdentifier(_ char: Character, withLexeme lexeme: String, atPosition pos: LexerPosition) throws -> LexerCharacterResult {
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

private func lexCharacter(_ char: Character, atState state: LexerState, withLexeme lexeme: String, atPosition pos: LexerPosition) throws -> LexerCharacterResult {
    return switch state {
        case .None:             lexCharacterInNone(char, withLexeme: lexeme, atPosition: pos)
        case .IntegerLiteral:   try lexCharacterInInteger(char, withLexeme: lexeme, atPosition: pos)
        case .CharacterLiteral: try lexCharacterInCharacter(char, withLexeme: lexeme, atPosition: pos)
        case .StringLiteral:    try lexCharacterInString(char, withLexeme: lexeme, atPosition: pos)
        case .Operator:         try lexCharacterInOperator(char, withLexeme: lexeme, atPosition: pos)
        case .Identifier:       try lexCharacterInIdentifier(char, withLexeme: lexeme, atPosition: pos)
    }
}

func displayLexerError(error: LexerException, lines: [String], tokenStartPos: LexerPosition) -> Void {
    let column = tokenStartPos.column + error.getColumnOffset()
    let line = lines[lines.index(lines.startIndex, offsetBy: tokenStartPos.lineNumber - 1)]
    
    print("<filename!>:\(tokenStartPos.lineNumber):\(column + 1): error: \(error.getReason())")
    print("\(line)")
    print("\(String(repeating: " ", count: column))^")
}

func lex(str: String) throws -> [Token] {
    var tokens: [Token] = []
    var state = LexerState.None
    var lexeme = ""
    var currentPos = LexerPosition(lineNumber: 1, column: 1, filename: "<filename!>")
    var tokenStartPos = currentPos
    
    /*
     * We add a whitespace character to the end so it can finsh off any token that it is
     * currently in when we hit the end of the file.
     */
    
    let lines = (str.split(separator: "\n") + [" "]).map({String($0)})
    for line in lines {
        for char in line {
            do {
                let result = try lexCharacter(char, atState: state, withLexeme: lexeme, atPosition: tokenStartPos)
                state = result.state
                lexeme = result.lexeme
                if let token = result.token {
                    tokens.append(token)
                    tokenStartPos = currentPos
                }
                if state == LexerState.None {
                    tokenStartPos = currentPos
                }
                
            } catch let error as LexerException {
                displayLexerError(
                    error: error,
                    lines: lines,
                    tokenStartPos: tokenStartPos
                )
                throw error
            }
            
            currentPos = LexerPosition(lineNumber: currentPos.lineNumber, column: currentPos.column + 1, filename: currentPos.filename)
        }
        
        currentPos = LexerPosition(lineNumber: currentPos.lineNumber + 1, column: 1, filename: currentPos.filename)
    }
    
    if state == LexerState.CharacterLiteral || state == LexerState.StringLiteral {
        displayLexerError(
            error: LexerException.unclosedStringOrCharacterLiteral(
                reason: "Unclosed \(state == LexerState.CharacterLiteral ? "character" : "string") literal.",
                columnOffset: lines[lines.index(lines.startIndex, offsetBy: tokenStartPos.lineNumber - 1)].count - 1
            ),
            lines: lines,
            tokenStartPos: tokenStartPos
        )
    }
    
    return tokens
}


func unitTestDemo() -> Int {
    return 5
}
