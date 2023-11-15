/*
 *  main.swift
 *  Compiler
 *
 *  Created by Alex on 14/11/2023.
 */

import Foundation

/*
 * This is a multiline comment.
 * I have to put the asterisk in manually, but at least XCode does the indent
 * for me.
 */

do {
    print(try lex(str: "hello world  0x12rf"))
} catch {}

do {
    print(try lex(str: "'a' 'b' '\\n' 'ab'"))
} catch {}

do {
    print(try lex(str: "'\\w'"))
} catch {}

do {
    print(try lex(str: "'\\"))
} catch {}

do {
    print(try lex(str: "\"this is a long string, but I forgot to terminate it!"))
} catch {}


let maybeContent = try? String(contentsOfFile: "/Users/alex/Desktop/Compiler/Tests/Files/test1.txt")
if let content = maybeContent {
    print(content)
}
