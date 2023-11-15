//
//  exception.swift
//  Compiler
//
//  Created by Alex on 14/11/2023.
//

import Foundation

enum LexerException: Error {
    case invalidLeadingZeroOnIntegerLiteral(String)
    case invalidIntegerLiteral(String)
    case invalidCharacterLiteral(String)
    case invalidEscapeCharacter(String)
    case integerLiteralExceedsBounds(String)
    case invalidOperatorException(String)
    case integerPrefixWithoutLiteral(String)
    case uppercaseIntegerPrefix(String)
    case invalidIntegerPrefix(String)
}
