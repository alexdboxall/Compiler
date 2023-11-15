//
//  strchar_tokens.swift
//  Compiler
//
//  Created by Alex on 15/11/2023.
//

import Foundation

private func resolveEscapeCodes(inString str: String) throws -> String {
    var result = ""
    var escaped = false
    var i = 0
    for char in str {
        if escaped {
            escaped = false
            switch char {
            case "n":
                result += "\n"
            case "t":
                result += "\t"
            case "r":
                result += "\r"
            case "\"":
                result += "\""
            case "'":
                result += "'"
            case "\\":
                result += "\\"
            default:
                throw LexerException.invalidEscapeCharacter(reason: "Invalid escape sequence \\\(char)", columnOffset: i)
            }
        } else if char == "\\" {
            escaped = true
        } else {
            result += String(char)
        }
        
        i += 1
    }
    if escaped {
        throw LexerException.invalidEscapeCharacter(reason: "Escape sequence isn't closed.", columnOffset: i)
    }
    return result
}

struct StringLiteralToken: Token {
    /*
     * Does not include quotes, and escape characters have already been taken care of.
     */
    let string: String
    
    init(potentiallyBackslashedString lexeme: String) throws {
        self.string = try resolveEscapeCodes(inString: lexeme)
    }
}

struct CharacterLiteralToken: Token {
    /*
     * Does not include quotes, and escape characters have already been taken care of.
     */
    let char: Character
    
    init(potentiallyBackslashedCharacter lexeme: String) throws {
        char = Character(try resolveEscapeCodes(inString: String(lexeme)))
    }
}
