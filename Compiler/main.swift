/*
 *  main.swift
 *  Compiler
 *
 *  Created by Alex on 14/11/2023.
 */

import Foundation

print("Hello, World!")

/*
 * This is a multiline comment.
 * I have to put the asterisk in manually, but at least XCode does the indent
 * for me.
 */

let maybeContent = try? String(contentsOfFile: "/Users/alex/Desktop/Compiler/Tests/Files/test1.txt")
if let content = maybeContent {
    print(content)
}
