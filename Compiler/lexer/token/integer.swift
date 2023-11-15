//
//  integerliteraltoken.swift
//  Compiler
//
//  Created by Alex on 15/11/2023.
//

import Foundation

struct IntegerLiteralToken: Token {
    /*
     * Includes the prefixes/suffixes, but not any underscores
     */
    let lexeme: String
    let underlyingValue: UInt64
    
    static private func getBaseOf(lexeme: String) -> Int {
        if lexeme.hasPrefix("0x") {
            return 16;
            
        } else if lexeme.hasPrefix("0b") {
            return 2;
            
        } else if lexeme.hasPrefix("0o") {
            return 8;
            
        } else {
            return 10;
        }
    }
    
    static private func convertToInt(literal: String, withBase base: Int) throws -> UInt64 {
        if (base == 10 && literal.hasPrefix("0") && literal.count > 1) {
            throw LexerException.invalidLeadingZeroOnIntegerLiteral(reason: "Decimal literals cannot start with a leading zero. Use the '0o' prefix for octal literals.")
        }
        
        if (literal.count == 0) {
            throw LexerException.integerPrefixWithoutLiteral(reason: "Expected integer literal after the prefix.", columnOffset: 2)
        }
        
        /*
         * Only contains the lookup characters allowed in this base (we take a slice of the full array).
         */
        let lookup: [Character] = Array(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"][0..<base])
        
        var value: UInt64 = 0;
        var columnOffset = base == 10 ? 0 : 2
        for char in literal.uppercased() {
            defer {
                columnOffset += 1
            }
            
            if char == "_" {
                continue
            }
            let (result, overflow) = value.multipliedReportingOverflow(by: UInt64(base))
            if overflow {
                throw LexerException.integerLiteralExceedsBounds(reason: "Integer literal \(literal) exceeds range of type.")
            }
            value = result
            if let lookupIndex = lookup.firstIndex(of: char) {
                let (result, overflow) = value.addingReportingOverflow(UInt64(lookupIndex.advanced(by: 0)))
                if overflow {
                    throw LexerException.integerLiteralExceedsBounds(reason: "Integer literal \(literal) exceeds range of type.")
                }
                value = result
            
            } else {
                throw LexerException.invalidIntegerLiteral(reason: "Invalid character found in integer literal.", columnOffset: columnOffset)
            }
        }
        
        return value;
    }
    
    static private func calculateUnderlyingValue(ofLexeme lexeme: String) throws -> UInt64 {
        let base = getBaseOf(lexeme: lexeme)
        if base == 10 {
            return try convertToInt(literal: lexeme, withBase: 10)
        } else {
            return try convertToInt(literal: String(lexeme.dropFirst(2)), withBase: base)
        }
    }
    
    init(lexeme: String) throws {
        try self.underlyingValue = IntegerLiteralToken.calculateUnderlyingValue(ofLexeme: lexeme)
        self.lexeme = lexeme
    }
}
