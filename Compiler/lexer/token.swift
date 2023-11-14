//
//  token.swift
//  Compiler
//
//  Created by Alex on 14/11/2023.
//

import Foundation

protocol Token {
    
}

struct IdentifierToken: Token {
    let lexeme: String
    
    init(lexeme: String) {
        self.lexeme = lexeme
    }
}

struct IntegerLiteralToken: Token {
    let lexeme: String
    let underlyingValue: UInt64
    
    static private func getBaseOf(lexeme: String) -> Int {
        if (lexeme.hasPrefix("0x")) {
            return 16;
        } else if (lexeme.hasPrefix("0b")) {
            return 2;
        } else if (lexeme.hasPrefix("0o")) {
            return 8;
        } else {
            return 10;
        }
    }
    
    static private func convertToInt(literal: String, withBase base: Int) throws -> UInt64 {
        if (base == 10 && literal.hasPrefix("0") && literal.count > 1) {
            throw LexerException.invalidLiteralError("Decimal literals cannot start with a leading zero. Use the '0o' prefix for octal literals.")
        }
        
        /*
         * Only contains the lookup characters allowed in this base (we take a slice of the full array).
         */
        let lookup: [Character] = Array(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"][0..<base])
        
        var value: UInt64 = 0;
        for char in literal.uppercased() {
            value *= UInt64(base)
            if let lookupIndex = lookup.firstIndex(of: char) {
                value += UInt64(lookupIndex.advanced(by: 0))
                
            } else {
                throw LexerException.invalidLiteralError("Invalid character \(char) found in integer literal.")
            }
        }
        
        return value;
    }
    
    static private func calculateUnderlyingValue(ofLexeme lexeme: String) throws -> UInt64 {
        var base = getBaseOf(lexeme: lexeme)
        if (base == 10) {
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

enum OperatorTokenType: Hashable {
    case Plus,                  // +
         Minus,                 // -
         Multiply,              // *
         Divide,                // /
         Modulo,                // %
         BitwiseAnd,            // &
         BitwiseOr,             // |
         BitwiseXor,            // ^
         ShiftLeft,             // <<
         ShiftRight,            // >>
         PlusEquals,            // +=
         MinusEquals,           // -=
         MultiplyEquals,        // *=
         DivideEquals,          // /=
         ModuloEquals,          // %=
         BitwiseAndEquals,      // &=
         BitwiseOrEquals,       // |=
         BitwiseXorEquals,      // ^=
         ShiftLeftEquals,       // <<=
         ShiftRightEquals,      // >>=
         OverflowPlus,          // &+
         OverflowMinus,         // &-
         OverflowMultiply,      // &*
         OverflowPlusEquals,    // &+=
         OverflowMinusEquals,   // &-=
         OverflowMultiplyEquals,// &*=
         ExclamationMark,       // !
         QuestionMark,          // ?
         DoubleQuestionMark,    // ??
         Semicolon,             // ;
         LogicalAnd,            // &&
         LogicalOr,             // ||
         Tilde,                 // ~
         Dot,                   // .
         Ellipsis,              // ...
         InclusiveRange,        // ..=
         ExclusiveRange,        // ..<
         Increment,             // ++
         Decrement,             // --
         Equals,                // =
         DoubleEquals,          // ==
         NotEquals,             // !=
         Colon,                 // :
         Comma,                 // ,
         Less,                  // <
         Greater,               // >
         LessOrEqual,           // <=
         GreaterOrEqual,        // >=
         LeftBracket,           // (
         RightBracket,          // )
         LeftSquareBracket,     // [
         RightSquareBracket,    // ]
         LeftCurlyBracket,      // {
         RightCurlyBracket,     // }
         LeftArrow,             // <-
         RightArrow             // ->
    
    case Var,
         Let,
         If,
         Func,
         Switch,
         Case,
         Int,
         String,
         Char,
         Bool,
         True,
         False,
         Nil,
         Default,
         Fallthrough,
         Void,
         Struct,
         Class,
         Else
}

struct OperatorToken: Token {
    let type: OperatorTokenType
    let lexeme: String
    
    static let tokenLookup = [
        "+"             : OperatorTokenType.Plus,
        "-"             : OperatorTokenType.Minus,
        "*"             : OperatorTokenType.Multiply,
        "/"             : OperatorTokenType.Divide,
        "%"             : OperatorTokenType.Modulo,
        "&"             : OperatorTokenType.BitwiseAnd,
        "|"             : OperatorTokenType.BitwiseOr,
        "^"             : OperatorTokenType.BitwiseXor,
        "<<"            : OperatorTokenType.ShiftLeft,
        ">>"            : OperatorTokenType.ShiftRight,
        "+="            : OperatorTokenType.PlusEquals,
        "-="            : OperatorTokenType.MinusEquals,
        "*="            : OperatorTokenType.MultiplyEquals,
        "/="            : OperatorTokenType.DivideEquals,
        "%="            : OperatorTokenType.ModuloEquals,
        "&="            : OperatorTokenType.BitwiseAndEquals,
        "|="            : OperatorTokenType.BitwiseOrEquals,
        "^="            : OperatorTokenType.BitwiseXorEquals,
        "<<="           : OperatorTokenType.ShiftLeftEquals,
        ">>="           : OperatorTokenType.ShiftRightEquals,
        "&+"            : OperatorTokenType.OverflowPlus,
        "&-"            : OperatorTokenType.OverflowMinus,
        "&*"            : OperatorTokenType.OverflowMultiply,
        "&+="           : OperatorTokenType.OverflowPlusEquals,
        "&-="           : OperatorTokenType.OverflowMinusEquals,
        "&*="           : OperatorTokenType.OverflowMultiplyEquals,
        "!"             : OperatorTokenType.ExclamationMark,
        "?"             : OperatorTokenType.QuestionMark,
        "??"            : OperatorTokenType.DoubleQuestionMark,
        ";"             : OperatorTokenType.Semicolon,
        "&&"            : OperatorTokenType.LogicalAnd,
        "||"            : OperatorTokenType.LogicalOr,
        "~"             : OperatorTokenType.Tilde,
        "."             : OperatorTokenType.Dot,
        "..."           : OperatorTokenType.Ellipsis,
        "..="           : OperatorTokenType.InclusiveRange,
        "..<"           : OperatorTokenType.ExclusiveRange,
        "++"            : OperatorTokenType.Increment,
        "--"            : OperatorTokenType.Decrement,
        "="             : OperatorTokenType.Equals,
        "=="            : OperatorTokenType.DoubleEquals,
        "!="            : OperatorTokenType.NotEquals,
        ":"             : OperatorTokenType.Colon,
        ","             : OperatorTokenType.Comma,
        "<"             : OperatorTokenType.Less,
        ">"             : OperatorTokenType.Greater,
        "<="            : OperatorTokenType.LessOrEqual,
        ">="            : OperatorTokenType.GreaterOrEqual,
        "("             : OperatorTokenType.LeftBracket,
        ")"             : OperatorTokenType.RightBracket,
        "["             : OperatorTokenType.LeftSquareBracket,
        "]"             : OperatorTokenType.RightSquareBracket,
        "{"             : OperatorTokenType.LeftCurlyBracket,
        "}"             : OperatorTokenType.RightCurlyBracket,
        "<-"            : OperatorTokenType.LeftArrow,
        "->"            : OperatorTokenType.RightArrow,
        
        "var"           : OperatorTokenType.Var,
        "let"           : OperatorTokenType.Let,
        "if"            : OperatorTokenType.If,
        "func"          : OperatorTokenType.Func,
        "switch"        : OperatorTokenType.Switch,
        "case"          : OperatorTokenType.Case,
        "Int"           : OperatorTokenType.Int,
        "String"        : OperatorTokenType.String,
        "Char"          : OperatorTokenType.Char,
        "Bool"          : OperatorTokenType.Bool,
        "true"          : OperatorTokenType.True,
        "false"         : OperatorTokenType.False,
        "nil"           : OperatorTokenType.Nil,
        "default"       : OperatorTokenType.Default,
        "fallthrough"   : OperatorTokenType.Fallthrough,
        "Void"          : OperatorTokenType.Void,
        "struct"        : OperatorTokenType.Struct,
        "class"         : OperatorTokenType.Class,
        "else"          : OperatorTokenType.Else
        
    ]
    
    static private func createReverseTokenLookup() -> Dictionary<OperatorTokenType, String> {
        var reverseMap = Dictionary<OperatorTokenType, String>()
        for mapping in tokenLookup {
            reverseMap[mapping.value] = mapping.key
        }
        return reverseMap
    }
    
    static let reverseTokenLookup = createReverseTokenLookup()
    
    init(type: OperatorTokenType) {
        self.type = type
        self.lexeme = OperatorToken.reverseTokenLookup[type]!
    }
    
    init(str: String) throws {
        self.init(type: OperatorToken.tokenLookup[str]!)
    }
    
    static func isStringValidStartOfToken(str: String) -> Bool {
        return tokenLookup.filter({$0.key.hasPrefix(str)}).count >= 0
    }
    
    static func isStringATerminalToken(str: String) -> Bool {
        return tokenLookup.filter({$0.key.hasPrefix(str)}).count == 1
    }
}

func test(token: Token) -> Void {
    switch token {
    case let tkn as IdentifierToken:
        print("The identifier is \(tkn.lexeme)")
        
    case let tkn as OperatorToken:
        switch tkn.type {
        case OperatorTokenType.Plus:
            print("add")
        case OperatorTokenType.Minus:
            print("sub")
        default:
            print("other")
        }
        
    default:
        print("unknown token!")
    }
}
