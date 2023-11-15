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

private func resolveEscapeCodes(inString str: String) throws -> String {
    var result = ""
    var escaped = false
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
                throw LexerException.invalidEscapeCharacter("Invalid escape sequence \\\(char)")
            }
        } else if char == "\\" {
            escaped = true
        } else {
            result += String(char)
        }
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
            throw LexerException.invalidLeadingZeroOnIntegerLiteral("Decimal literals cannot start with a leading zero. Use the '0o' prefix for octal literals.")
        }
        
        if (literal.count == 0) {
            throw LexerException.integerPrefixWithoutLiteral("Expected integer literal after the prefix.")
        }
        
        /*
         * Only contains the lookup characters allowed in this base (we take a slice of the full array).
         */
        let lookup: [Character] = Array(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"][0..<base])
        
        var value: UInt64 = 0;
        for char in literal.uppercased() {
            if char == "_" {
                continue
            }
            let (result, overflow) = value.multipliedReportingOverflow(by: UInt64(base))
            if overflow {
                throw LexerException.integerLiteralExceedsBounds("Integer literal \(literal) exceeds range of type.")
            }
            value = result
            if let lookupIndex = lookup.firstIndex(of: char) {
                let (result, overflow) = value.addingReportingOverflow(UInt64(lookupIndex.advanced(by: 0)))
                if overflow {
                    throw LexerException.integerLiteralExceedsBounds("Integer literal \(literal) exceeds range of type.")
                }
                value = result
            
            } else {
                throw LexerException.invalidIntegerLiteral("Invalid character \(char) found in integer literal.")
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
    
    static let tokenLookup: Dictionary<String, OperatorTokenType> = [
        "+"             : .Plus,
        "-"             : .Minus,
        "*"             : .Multiply,
        "/"             : .Divide,
        "%"             : .Modulo,
        "&"             : .BitwiseAnd,
        "|"             : .BitwiseOr,
        "^"             : .BitwiseXor,
        "<<"            : .ShiftLeft,
        ">>"            : .ShiftRight,
        "+="            : .PlusEquals,
        "-="            : .MinusEquals,
        "*="            : .MultiplyEquals,
        "/="            : .DivideEquals,
        "%="            : .ModuloEquals,
        "&="            : .BitwiseAndEquals,
        "|="            : .BitwiseOrEquals,
        "^="            : .BitwiseXorEquals,
        "<<="           : .ShiftLeftEquals,
        ">>="           : .ShiftRightEquals,
        "&+"            : .OverflowPlus,
        "&-"            : .OverflowMinus,
        "&*"            : .OverflowMultiply,
        "&+="           : .OverflowPlusEquals,
        "&-="           : .OverflowMinusEquals,
        "&*="           : .OverflowMultiplyEquals,
        "!"             : .ExclamationMark,
        "?"             : .QuestionMark,
        "??"            : .DoubleQuestionMark,
        ";"             : .Semicolon,
        "&&"            : .LogicalAnd,
        "||"            : .LogicalOr,
        "~"             : .Tilde,
        "."             : .Dot,
        "..."           : .Ellipsis,
        "..="           : .InclusiveRange,
        "..<"           : .ExclusiveRange,
        "++"            : .Increment,
        "--"            : .Decrement,
        "="             : .Equals,
        "=="            : .DoubleEquals,
        "!="            : .NotEquals,
        ":"             : .Colon,
        ","             : .Comma,
        "<"             : .Less,
        ">"             : .Greater,
        "<="            : .LessOrEqual,
        ">="            : .GreaterOrEqual,
        "("             : .LeftBracket,
        ")"             : .RightBracket,
        "["             : .LeftSquareBracket,
        "]"             : .RightSquareBracket,
        "{"             : .LeftCurlyBracket,
        "}"             : .RightCurlyBracket,
        "<-"            : .LeftArrow,
        "->"            : .RightArrow,
        
        "var"           : .Var,
        "let"           : .Let,
        "if"            : .If,
        "func"          : .Func,
        "switch"        : .Switch,
        "case"          : .Case,
        "Int"           : .Int,
        "String"        : .String,
        "Char"          : .Char,
        "Bool"          : .Bool,
        "true"          : .True,
        "false"         : .False,
        "nil"           : .Nil,
        "default"       : .Default,
        "fallthrough"   : .Fallthrough,
        "Void"          : .Void,
        "struct"        : .Struct,
        "class"         : .Class,
        "else"          : .Else
        
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
    
    init(str: String) {
        self.init(type: OperatorToken.tokenLookup[str]!)
    }
    
    static func isStringValidStartOfToken(str: String) -> Bool {
        return tokenLookup.filter({$0.key.hasPrefix(str)}).count >= 0
    }
    
    static func isStringATerminalToken(str: String) -> Bool {
        return tokenLookup.filter({$0.key.hasPrefix(str)}).count == 1
    }
    
    static func isStringAValidToken(str: String) -> Bool {
        return tokenLookup.keys.contains(str)
    }
}

func test(token: Token) -> Void {
    switch token {
    case let tkn as IdentifierToken:
        print("The identifier is \(tkn.lexeme)")
        
    case let tkn as OperatorToken:
        switch tkn.type {
        case .Plus:
            print("add")
        case .Minus:
            print("sub")
        default:
            print("other")
        }
        
    default:
        print("unknown token!")
    }
}
