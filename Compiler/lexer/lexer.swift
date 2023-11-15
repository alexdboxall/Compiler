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

func lexCharacter(_ char: Character, atState state: LexerState, withLexeme lexeme: String, atPosition pos: LexerPosition) throws -> LexerCharacterResult {
    return switch state {
        case .None:                 lexCharacterInNone(char, withLexeme: lexeme, atPosition: pos)
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
    
    print("\(tokenStartPos.filename):\(tokenStartPos.lineNumber):\(column + 1): error: \(error.getReason())")
    print("\(line)")
    print("\(String(repeating: " ", count: column))^")
}

func lex(str: String, _ filename: String = "<unknown-file>") throws -> [Token] {
    var tokens: [Token] = []
    var state = LexerState.None
    var lexeme = ""
    var currentPos = LexerPosition(lineNumber: 1, column: 1, filename: filename)
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
        let error = LexerException.unclosedStringOrCharacterLiteral(
            reason: "Unclosed \(state == LexerState.CharacterLiteral ? "character" : "string") literal.",
            columnOffset: lines[lines.index(lines.startIndex, offsetBy: tokenStartPos.lineNumber - 1)].count - 1
        )
        
        displayLexerError(
            error: error,
            lines: lines,
            tokenStartPos: tokenStartPos
        )
        
        throw error
    }
    
    return tokens
}


func unitTestDemo() -> Int {
    return 5
}
