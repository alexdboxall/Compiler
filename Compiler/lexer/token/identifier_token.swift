//
//  identifier_token.swift
//  Compiler
//
//  Created by Alex on 15/11/2023.
//

import Foundation

struct IdentifierToken: Token {
    let lexeme: String
    
    init(lexeme: String) {
        self.lexeme = lexeme
    }
}
