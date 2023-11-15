//
//  operator_token.swift
//  Compiler
//
//  Created by Alex on 15/11/2023.
//

import Foundation

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
         True,
         False,
         Nil,
         Default,
         Fallthrough,
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
        "true"          : .True,
        "false"         : .False,
        "nil"           : .Nil,
        "default"       : .Default,
        "fallthrough"   : .Fallthrough,
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

