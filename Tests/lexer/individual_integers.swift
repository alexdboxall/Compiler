//
//  Tests.swift
//  Tests
//
//  Created by Alex on 14/11/2023.
//

import XCTest
import Compiler

final class LexerIndividualIntegerTests: XCTestCase {
    func testLiteralThatsTooLarge() throws {
        do {
            let _ = try lex(str: "123456789123456789123456789")
            XCTFail()
        } catch (e: LexerException.integerLiteralExceedsBounds) {}
    }
    
    func testHexLiteralThatsTooLarge() throws {
        do {
            let _ = try lex(str: "0x1_0000_0000_0000_0000")
            XCTFail()
        } catch (e: LexerException.integerLiteralExceedsBounds) {}
    }
    
    func testIntegerWithLeadingZero() throws {
        do {
            let _ = try lex(str: "0345")
            XCTFail()
        } catch (e: LexerException.invalidLeadingZeroOnIntegerLiteral) {}
    }
    
    func testThatLeadingUnderscoreMeansNotAnInteger() throws {
        let result = try lex(str: "_123")
        if let firstItem = result.first as? IdentifierToken {
            XCTAssertEqual(firstItem.lexeme, "_123")
        } else {
            XCTFail()
        }
    }
    
    func testJust0x() throws {
        do {
            let _ = try lex(str: "0x")
            XCTFail()
        } catch (e: LexerException.integerPrefixWithoutLiteral) {}
    }
    
    func testJust0o() throws {
        do {
            let _ = try lex(str: "0o")
            XCTFail()
        } catch (e: LexerException.integerPrefixWithoutLiteral) {}
    }
    
    func testJust0b() throws {
        do {
            let _ = try lex(str: "0b")
            XCTFail()
        } catch (e: LexerException.integerPrefixWithoutLiteral) {}
    }
    
    func testInvalidCharacterInInteger() throws {
        do {
            let _ = try lex(str: "123Z456")
            XCTFail()
        } catch (e: LexerException.invalidIntegerLiteral) {}
    }
    
    func testUnderscoreMidPrefix0x() throws {
        do {
            let _ = try lex(str: "0_x123")
            XCTFail()
        } catch (e: LexerException.invalidLeadingZeroOnIntegerLiteral) {}
    }
    
    func testUnderscoreMidPrefix0b() throws {
        do {
            let _ = try lex(str: "0_b010")
            XCTFail()
        } catch (e: LexerException.invalidLeadingZeroOnIntegerLiteral) {}
    }
    
    func testUnderscoreMidPrefix0o() throws {
        do {
            let _ = try lex(str: "0_o123")
            XCTFail()
        } catch (e: LexerException.invalidLeadingZeroOnIntegerLiteral) {}
    }
    
    func testInvalidHexDigit() throws {
        do {
            let _ = try lex(str: "0x12G4")
            XCTFail()
        } catch (e: LexerException.invalidIntegerLiteral) {}
    }
    
    func testInvalidBinaryDigit() throws {
        do {
            let _ = try lex(str: "0b01210")
            XCTFail()
        } catch (e: LexerException.invalidIntegerLiteral) {}
    }
    
    func testInvalidOctalDigit() throws {
        do {
            let _ = try lex(str: "0b246842")
            XCTFail()
        } catch (e: LexerException.invalidIntegerLiteral) {}
    }
    
    func testInvalidDecimalDigit() throws {
        do {
            let _ = try lex(str: "123ABC")
            XCTFail()
        } catch (e: LexerException.invalidIntegerLiteral) {}
    }
    
    func testUppercasePrefix0X() throws {
        do {
            let _ = try lex(str: "0X111")
            XCTFail()
        } catch (e: LexerException.uppercaseIntegerPrefix) {}
    }
    
    func testUppercasePrefix0B() throws {
        do {
            let _ = try lex(str: "0B111")
            XCTFail()
        } catch (e: LexerException.uppercaseIntegerPrefix) {}
    }
    
    func testUppercasePrefix0O() throws {
        do {
            let _ = try lex(str: "0O111")
            XCTFail()
        } catch (e: LexerException.uppercaseIntegerPrefix) {}
    }
    
    func testInvalidPrefix1() throws {
        do {
            let _ = try lex(str: "0j12345")
            XCTFail()
        } catch (e: LexerException.invalidIntegerPrefix) {}
    }
    
    func testInvalidPrefix2() throws {
        do {
            let _ = try lex(str: "0z12345")
            XCTFail()
        } catch (e: LexerException.invalidIntegerPrefix) {}
    }
    
    func testDoublePrefix1() throws {
        do {
            let _ = try lex(str: "0x0x1234")
            XCTFail()
        } catch (e: LexerException.invalidIntegerLiteral) {}
    }
    
    func testDoublePrefix2() throws {
        do {
            let _ = try lex(str: "0o0b1234")
            XCTFail()
        } catch (e: LexerException.invalidIntegerLiteral) {}
    }
    
    func testDoublePrefix3() throws {
        do {
            let _ = try lex(str: "0xx234")
            XCTFail()
        } catch (e: LexerException.invalidIntegerLiteral) {}
    }
    
    private func doSuccessTest(input: String, expectedLexeme: String, expectedValue: UInt64) throws {
        let result = try lex(str: input)
        XCTAssertEqual(result.count, 1)
        if let firstItem = result.first as? IntegerLiteralToken {
            XCTAssertEqual(firstItem.lexeme, expectedLexeme)
            XCTAssertEqual(firstItem.underlyingValue, expectedValue)
        } else {
            XCTFail()
        }
    }
    
    func testLiteralAtRangeLimit() throws {
        try doSuccessTest(input: "0xFFFF_FFFF_FFFF_FFFF", expectedLexeme: "0xFFFF_FFFF_FFFF_FFFF", expectedValue: 0xFFFFFFFFFFFFFFFF)
    }
    
    func testUnderscoreAfter0o() throws {
        try doSuccessTest(input: "0o___3", expectedLexeme: "0o___3", expectedValue: 3)
    }
    
    func testUnderscoreAfter0b() throws {
        try doSuccessTest(input: "0b_1010_1010", expectedLexeme: "0b_1010_1010", expectedValue: 0b10101010)
    }
    
    func testUnderscoreAfter0x() throws {
        try doSuccessTest(input: "0x_5500_56", expectedLexeme: "0x_5500_56", expectedValue: 0x550056)
    }
    
    func testUnderscoredInteger1() throws {
        try doSuccessTest(input: "35_123_456", expectedLexeme: "35_123_456", expectedValue: 35123456)
    }
    
    func testUnderscoredInteger2() throws {
        try doSuccessTest(input: "1_2_3_4_5_6", expectedLexeme: "1_2_3_4_5_6", expectedValue: 123456)
    }
    
    func testLotsOfUnderscores() throws {
        try doSuccessTest(input: "43______7______", expectedLexeme: "43______7______", expectedValue: 437)
    }
    
    func testRegularInteger() throws {
        try doSuccessTest(input: "35", expectedLexeme: "35", expectedValue: 35)
    }
    
    func testZeroInteger() throws {
        try doSuccessTest(input: "0", expectedLexeme: "0", expectedValue: 0)
    }
    
    func testHexadecimalInteger1() throws {
        try doSuccessTest(input: "0x123ABC", expectedLexeme: "0x123ABC", expectedValue: 0x123ABC)
    }
    
    func testHexadecimalInteger2() throws {
        try doSuccessTest(input: "0xFFFF", expectedLexeme: "0xFFFF", expectedValue: 0xFFFF)
    }
    
    func testHexadecimalInteger3() throws {
        try doSuccessTest(input: "0x000000", expectedLexeme: "0x000000", expectedValue: 0x000000)
    }
    
    func testHexadecimalInteger4() throws {
        try doSuccessTest(input: "0x4567890DE", expectedLexeme: "0x4567890DE", expectedValue: 0x4567890DE)
    }
    
    func testBinaryInteger1() throws {
        try doSuccessTest(input: "0b110101011", expectedLexeme: "0b110101011", expectedValue: 0b110101011)
    }
    
    func testBinaryInteger2() throws {
        try doSuccessTest(input: "0b000", expectedLexeme: "0b000", expectedValue: 0b0)
    }
    
    func testOctalInteger1() throws {
        try doSuccessTest(input: "0o12345670101", expectedLexeme: "0o12345670101", expectedValue: 0o12345670101)
    }
    
    func testOctalInteger2() throws {
        try doSuccessTest(input: "0o00000", expectedLexeme: "0o00000", expectedValue: 0b0)
    }
}
