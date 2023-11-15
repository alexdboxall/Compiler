//
//  exception.swift
//  Compiler
//
//  Created by Alex on 14/11/2023.
//

import Foundation

enum LexerException: Error {
    case invalidLeadingZeroOnIntegerLiteral(reason: String, columnOffset: Int = 0)
    case invalidIntegerLiteral(reason: String, columnOffset: Int = 0)
    case invalidCharacterLiteral(reason: String, columnOffset: Int = 0)
    case invalidEscapeCharacter(reason: String, columnOffset: Int = 0)
    case integerLiteralExceedsBounds(reason: String, columnOffset: Int = 0)
    case invalidOperatorException(reason: String, columnOffset: Int = 0)
    case integerPrefixWithoutLiteral(reason: String, columnOffset: Int = 0)
    case uppercaseIntegerPrefix(reason: String, columnOffset: Int = 0)
    case invalidIntegerPrefix(reason: String, columnOffset: Int = 0)
    case unclosedStringOrCharacterLiteral(reason: String, columnOffset: Int = 0)
    
    func getReason() -> String {
        return switch self {
        case let .invalidLeadingZeroOnIntegerLiteral(reason, _): reason
        case let .invalidIntegerLiteral(reason, _): reason
        case let .invalidCharacterLiteral(reason, _): reason
        case let .invalidEscapeCharacter(reason, _): reason
        case let .integerLiteralExceedsBounds(reason, _): reason
        case let .invalidOperatorException(reason, _): reason
        case let .integerPrefixWithoutLiteral(reason, _): reason
        case let .uppercaseIntegerPrefix(reason, _): reason
        case let .invalidIntegerPrefix(reason, _): reason
        case let .unclosedStringOrCharacterLiteral(reason, _): reason
        }
    }
    
    func getColumnOffset() -> Int {
        return switch self {
        case let .invalidLeadingZeroOnIntegerLiteral(_, columnOffset): columnOffset
        case let .invalidIntegerLiteral(_, columnOffset): columnOffset
        case let .invalidCharacterLiteral(_, columnOffset): columnOffset
        case let .invalidEscapeCharacter(_, columnOffset): columnOffset
        case let .integerLiteralExceedsBounds(_, columnOffset): columnOffset
        case let .invalidOperatorException(_, columnOffset): columnOffset
        case let .integerPrefixWithoutLiteral(_, columnOffset): columnOffset
        case let .uppercaseIntegerPrefix(_, columnOffset): columnOffset
        case let .invalidIntegerPrefix(_, columnOffset): columnOffset
        case let .unclosedStringOrCharacterLiteral(_, columnOffset): columnOffset
        }
    }
}
