import XCTest
@testable import YAJL

class ParsingTests: XCTestCase {
    
    func test_FailOnEmpty() {
        expectThrow("")
    }
    
    func test_CompletelyWrong() {
        expectThrow("<XML>")
    }
    
    func testExtraTokensThrow() {
        expectThrow("{'hello':'world'} blah")
    }
    
    
    // MARK: - Null
    
    func testNullParses() {
        expect("null", toParseTo: .null)
    }
    
    func testNullThrowsOnMismatch() {
        expectThrow("nall")
    }
    
    func testNullSkipInObject() {
        //    expect("{'key': null}", toParseTo: [:], withOptions: .omitNulls)
    }
    
    func testNullSkipInArray() {
        //    expect("['someString', true, null, 1]", toParseTo: ["someString", true, 1], withOptions: .omitNulls)
    }
    
    func testNullSkipFragment() {
        // not sure what to expect here. but so long as it's consistent.
        //    expect("null", toParseTo: .null, withOptions: [.omitNulls, .allowFragments])
    }

//    FIXME
//    func testFragmentNormallyThrows() {
//        expectThrow("'frag out'")
//    }
    
    
    // MARK: - Bools
    
    func testTrueParses() {
        expect("true", toParseTo: .bool(true))
    }
    
    func testTrueThrowsOnMismatch() {
        expectThrow("tRue")
    }
    
    func testFalseParses() {
        expect("false", toParseTo: .bool(false))
    }
    
    func testBoolean_False_Mismatch() {
        expectThrow("fals ")
    }
    
    
    // MARK: - Arrays
    
    func testArray_JustComma() {
        expectThrow("[,]")
    }
    
    func testArray_JustNull() {
        expect("[ null ]", toParseTo: .array([.null]))
    }
    
    func testArray_ZeroBegining() {
        expect("[0, 1] ", toParseTo: .array([.int(0), .int(1)]))
    }
    
    func testArray_ZeroBeginingWithWhitespace() {
        expect("[0            , 1] ", toParseTo: .array([.int(0), .int(1)]))
    }
    
    func testArray_NullsBoolsNums_Normal_Minimal_RootParser() {
        expect("[null,true,false,12,-10,-24.3,18.2e9]", toParseTo:
            .array([.null, .bool(true), .bool(false), .int(12), .int(-10), .double(-24.3), .double(18200000000.0)])
        )
    }
    
    func testArray_NullsBoolsNums_Normal_MuchWhitespace() {
        expect(" \t[\n  null ,true, \n-12.3 , false\r\n]\n  ", toParseTo:
            .array([.null, .bool(true), .double(-12.3), .bool(false)])
        )
    }
    
    func testArray_NullsAndBooleans_Bad_MissingEnd() {
        expectThrow("[\n  null ,true, \nfalse\r\n\n  ")
    }
    
    func testArray_NullsAndBooleans_Bad_MissingComma() {
        expectThrow("[\n  null true, \nfalse\r\n]\n  ")
    }
    
    func testArray_NullsAndBooleans_Bad_ExtraComma() {
        expectThrow("[\n  null , , true, \nfalse\r\n]\n  ")
    }
    
    func testArray_NullsAndBooleans_Bad_TrailingComma() {
        expectThrow("[\n  null ,true, \nfalse\r\n, ]\n  ")
    }
    
    
    // MARK: - Numbers
    
    func testNumber_Int_ZeroWithTrailingWhitespace() {
        expect("0 ", toParseTo: .int(0))
    }
    
    func testNumber_Int_Zero() {
        expect("0", toParseTo: .int(0))
    }
    
    func testNumber_Int_One() {
        expect("1", toParseTo: .int(1))
    }
    
    func testNumber_Int_Basic() {
        expect("24", toParseTo: .int(24))
    }
    
//    FIXME
//    func testNumber_IntMin() {
//        expect(Int.min.description, toParseTo: .int(Int.min))
//    }
    
    func testNumber_IntMax() {
        expect(Int.max.description, toParseTo: .int(Int.max))
    }
    
    func testNumber_Int_Negative() {
        expect("-32", toParseTo: .int(-32))
    }
    
    func testNumber_Int_Garbled() {
        expectThrow("42-4")
    }
    
    func testNumber_Int_LeadingZero() {
        expectThrow("007")
    }
    
    func testNumber_Int_Overflow() {
        expectThrow("9223372036854775808")
        expectThrow("18446744073709551616")
        expectThrow("18446744073709551616")
    }
    
//    FIXME
//    func testNumber_Double_Overflow() {
//        expectThrow("18446744073709551616.0")
//        expectThrow("1.18446744073709551616")
//        expectThrow("1e18446744073709551616")
//        expectThrow("184467440737095516106.0")
//        expectThrow("1.184467440737095516106")
//        expectThrow("1e184467440737095516106")
//    }
    
    func testNumber_Dbl_LeadingZero() {
        expectThrow("006.123")
    }
    
    func testNumber_Dbl_Basic() {
        expect("46.57", toParseTo: .double(46.57))
    }
    
    func testNumber_Dbl_ZeroSomething() {
        expect("0.98", toParseTo: .double(0.98))
    }
    
    func testNumber_Dbl_MinusZeroSomething() {
        expect("-0.98", toParseTo: .double(-0.98))
    }
    
    func testNumber_Dbl_ThrowsOnMinus() {
        expectThrow("-")
    }
    
    func testNumber_Dbl_Incomplete() {
        expectThrow("24.")
    }
    
    func testNumber_Dbl_Negative() {
        expect("-24.34", toParseTo: .double(-24.34))
    }
    
    func testNumber_Dbl_Negative_WrongChar() {
        expectThrow("-24.3a4")
    }
    
    func testNumber_Dbl_Negative_TwoDecimalPoints() {
        expectThrow("-24.3.4")
    }
    
    func testNumber_Dbl_Negative_TwoMinuses() {
        expectThrow("--24.34")
    }
    
    func testNumber_Double_Exp_Normal() {
        expect("-24.3245e2", toParseTo: .double(-2432.45))
    }
    
    func testNumber_Double_Exp_Positive() {
        expect("-24.3245e+2", toParseTo: .double(-2432.45))
    }
    
    // TODO (vdka): floating point accuracy
    // Potential to fix through using Darwin.C.pow but, isn't that a dependency?
    // Maybe reimplement C's gross lookup table pow method
    // http://opensource.apple.com/source/Libm/Libm-2026/Source/Intel/expf_logf_powf.c
    // http://opensource.apple.com/source/Libm/Libm-315/Source/ARM/powf.c
    // May be hard to do this fast and correct in pure swift.
    func testNumber_Double_Exp_Negative() {
        // FIXME (vdka): Fix floating point number types
        expect("-24.3245e-2", toParseTo: .double(-24.3245e-2))
    }
    
    func testNumber_Double_ExactnessNoExponent() {
        expect("-123451123442342.12124234", toParseTo: .double(-123451123442342.12124234))
    }
    
    func testNumber_Double_ExactnessWithExponent() {
        expect("-123456789.123456789e-150", toParseTo: .double(-123456789.123456789e-150))
    }
    
    func testNumber_Double_Exp_NoFrac() {
        expect("24E2", toParseTo: .double(2400.0))
    }
    
    func testNumber_Double_Exp_TwoEs() {
        expectThrow("-24.3245eE2")
    }
    
    
    // MARK: - Strings & Unicode
    
    func testEscape_Solidus() {
        expect("'\\/'", toParseTo: .string("/"))
    }
    
    func testLonelyReverseSolidus() {
        expectThrow("'\\'")
    }
    
    func testEscape_Unicode_Normal() {
        expect("'\\u0048'", toParseTo: .string("H"))
    }
    
    func testEscape_Unicode_Invalid() {
        expectThrow("'\\uD83d\\udQ24'")
    }
    
    func testEscape_Unicode_Complex() {
        expect("'\\ud83d\\ude24'", toParseTo: .string("\u{1F624}"))
    }
    
    func testEscape_Unicode_Complex_MixedCase() {
        expect("'\\uD83d\\udE24'", toParseTo: .string("\u{1F624}"))
    }
    
    func testEscape_Unicode_InvalidUnicode_MissingDigit() {
        expectThrow("'\\u048'")
    }
    
    func testEscape_Unicode_InvalidUnicode_MissingAllDigits() {
        expectThrow("'\\u'")
    }
    
    func testString_Empty() {
        expect("''", toParseTo: .string(""))
    }
    
    func testString_Normal() {
        expect("'hello world'", toParseTo: .string("hello world"))
    }
    
    func testString_Normal_Backslashes() {
        // This looks insane and kinda is. The rule is the right side just halve, the left side quarter.
        expect("'C:\\\\\\\\share\\\\path\\\\file'", toParseTo: .string("C:\\\\share\\path\\file"))
    }
    
    func testString_Normal_WhitespaceInside() {
        expect("'he \\r\\n l \\t l \\n o wo\\rrld '", toParseTo: .string("he \r\n l \t l \n o wo\rrld "))
    }
    
    func testString_StartEndWithSpaces() {
        expect("'  hello world  '", toParseTo: .string("  hello world  "))
    }

//    FIXME
//    func testString_Unicode_NoTrailingSurrogate() {
//        expectThrow("'\\ud83d'")
//    }

//    FIXME
//    func testString_Unicode_InvalidTrailingSurrogate() {
//        expectThrow("'\\ud83d\\u0040'")
//    }
    
    func testString_Unicode_RegularChar() {
        expect("'hel\\u006co world'", toParseTo: .string("hello world"))
    }
    
    func testString_Unicode_SpecialCharacter_CoolA() {
        expect("'h\\u01cdw'", toParseTo: .string("hǍw"))
    }
    
    func testString_Unicode_SpecialCharacter_HebrewShin() {
        expect("'h\\u05e9w'", toParseTo: .string("hשw"))
    }
    
    func testString_Unicode_SpecialCharacter_QuarterTo() {
        expect("'h\\u25d5w'", toParseTo: .string("h◕w"))
    }
    
    func testString_Unicode_SpecialCharacter_EmojiSimple() {
        expect("'h\\ud83d\\ude3bw'", toParseTo: .string("h😻w"))
    }
    
    func testString_Unicode_SpecialCharacter_EmojiComplex() {
        expect("'h\\ud83c\\udde8\\ud83c\\uddffw'", toParseTo: .string("h🇨🇿w"))
    }
    
    func testString_SpecialCharacter_QuarterTo() {
        expect("'h◕w'", toParseTo: .string("h◕w"))
    }
    
    func testString_SpecialCharacter_EmojiSimple() {
        expect("'h😻w'", toParseTo: .string("h😻w"))
    }
    
    func testString_SpecialCharacter_EmojiComplex() {
        expect("'h🇨🇿w'", toParseTo: .string("h🇨🇿w"))
    }
    
    func testString_BackspaceEscape() {
        let backspace = Character(UnicodeScalar(0x08))
        expect("'\\b'", toParseTo: .string(String(backspace)))
    }
    
    func testEscape_FormFeed() {
        let formfeed = Character(UnicodeScalar(0x0C))
        expect("'\\f'", toParseTo: .string(String(formfeed)))
    }
    
    func testString_ContainingEscapedQuotes() {
        expect("'\\\"\\\"'", toParseTo: .string("\"\""))
    }
    
    func testString_ContainingSlash() {
        expect("'http:\\/\\/example.com'", toParseTo: .string("http://example.com"))
    }
    
    func testString_ContainingInvalidEscape() {
        expectThrow("'\\a'")
    }
    
    
    // MARK: - Objects
    
    func testObject_Empty() {
        expect("{}", toParseTo: .dictionary([:]))
    }
    
    func testObject_JustComma() {
        expectThrow("{,}")
    }
    
    func testObject_SyntaxError() {
        expectThrow("{'hello': 'failure'; 'goodbye': true}")
    }
    
    func testObject_TrailingComma() {
        expectThrow("{'someKey': true,,}")
    }
    
    func testObject_MissingComma() {
        expectThrow("{'someKey': true 'someOther': false}")
    }
    
    func testObject_MissingColon() {
        expectThrow("{'someKey' true}")
    }
    
    func testObject_Example1() {
        expect("{\t'hello': 'wor🇨🇿ld', \n\t 'val': 1234, 'many': [\n-12.32, null, 'yo'\r], 'emptyDict': {}, 'dict': {'arr':[]}, 'name': true}", toParseTo:
            .dictionary([
                "hello": .string("wor🇨🇿ld"),
                "val": .int(1234),
                "many": .array([.double(-12.32), .null, .string("yo")]),
                "emptyDict": .dictionary([:]),
                "dict": .dictionary(["arr": .array([])]),
                "name": .bool(true)
                ])
        )
    }
    
    func testTrollBlockComment() {
        expectThrow("/*/ {'key':'harry'}")
    }
    
    func testLineComment_start() {
        expect("// This is a comment\n{'key':true}", toParseTo: .dictionary(["key": .bool(true)]), options: [.allowComments])
    }
    
    
    func testLineComment_endWithNewline() {
        expect("// This is a comment\n{'key':true}", toParseTo: .dictionary(["key": .bool(true)]), options: [.allowComments])
        expect("{'key':true}// This is a comment\n", toParseTo: .dictionary(["key": .bool(true)]), options: [.allowComments])
    }
    
    func testLineComment_end() {
        expect("{'key':true}// This is a comment", toParseTo: .dictionary(["key": .bool(true)]), options: [.allowComments])
        expect("{'key':true}\n// This is a comment", toParseTo: .dictionary(["key": .bool(true)]), options: [.allowComments])
    }
    
    func testBlockComment_start() {
        expect("/* This is a comment */{'key':true}", toParseTo: .dictionary(["key": .bool(true)]), options: [.allowComments])
    }
    
    func testBlockComment_end() {
        expect("{'key':true}/* This is a comment */", toParseTo: .dictionary(["key": .bool(true)]), options: [.allowComments])
        expect("{'key':true}\n/* This is a comment */", toParseTo: .dictionary(["key": .bool(true)]), options: [.allowComments])
    }

//    FIXME
//    func testBlockCommentNested() {
//        expect("[true] a /* b  /* c */ d */", toParseTo: .array([.bool(true)]))
//    }
}

extension ParsingTests {
    
    func expect(_ input: String, toParseTo expected: Map, options: JSONParserOptions = [], file: StaticString = #file, line: UInt = #line) {
        let input = input.replacingOccurrences(of: "'", with: "\"")
        
        let data = Array(input.utf8)
        
        do {
            let output = try JSONParser.parse(data, options: options)
            XCTAssertEqual(output.description, expected.description, file: file, line: line)
        } catch {
            XCTFail("\(error)", file: file, line: line)
        }
    }
    
    func expectThrow(_ input: String, file: StaticString = #file, line: UInt = #line) {
        let input = input.replacingOccurrences(of: "'", with: "\"")
        
        let data = Array(input.utf8)
        
        do {
            _ = try JSONParser.parse(data)
            XCTFail("Expected throw", file: file, line: line)
        } catch {
            // no-op
        }
    }
}

#if os(Linux)
    extension ParsingTests {
        static var allTests : [(String, (ParsingTests) -> () throws -> Void)] {
            return [
                ("test_FailOnEmpty", testPrepareForReading_FailOnEmpty),
                ("testExtraTokensThrow", testExtraTokensThrow),
                ("testNullParses", testNullParses),
                ("testNullThrowsOnMismatch", testNullThrowsOnMismatch),
                ("testTrueParses", testTrueParses),
                ("testTrueThrowsOnMismatch", testTrueThrowsOnMismatch),
                ("testFalseParses", testFalseParses),
                ("testBoolean_False_Mismatch", testBoolean_False_Mismatch),
                ("testArray_NullsBoolsNums_Normal_Minimal_RootParser", testArray_NullsBoolsNums_Normal_Minimal_RootParser),
                ("testArray_NullsBoolsNums_Normal_MuchWhitespace", testArray_NullsBoolsNums_Normal_MuchWhitespace),
                ("testArray_NullsAndBooleans_Bad_MissingEnd", testArray_NullsAndBooleans_Bad_MissingEnd),
                ("testArray_NullsAndBooleans_Bad_MissingComma", testArray_NullsAndBooleans_Bad_MissingComma),
                ("testArray_NullsAndBooleans_Bad_ExtraComma", testArray_NullsAndBooleans_Bad_ExtraComma),
                ("testArray_NullsAndBooleans_Bad_TrailingComma", testArray_NullsAndBooleans_Bad_TrailingComma),
                ("testNumber_Int_Zero", testNumber_Int_Zero),
                ("testNumber_Int_One", testNumber_Int_One),
                ("testNumber_Int_Basic", testNumber_Int_Basic),
                ("testNumber_Int_Negative", testNumber_Int_Negative),
                ("testNumber_Dbl_Basic", testNumber_Dbl_Basic),
                ("testNumber_Dbl_ZeroSomething", testNumber_Dbl_ZeroSomething),
                ("testNumber_Dbl_MinusZeroSomething", testNumber_Dbl_MinusZeroSomething),
                ("testNumber_Dbl_Incomplete", testNumber_Dbl_Incomplete),
                ("testNumber_Dbl_Negative", testNumber_Dbl_Negative),
                ("testNumber_Dbl_Negative_WrongChar", testNumber_Dbl_Negative_WrongChar),
                ("testNumber_Dbl_Negative_TwoDecimalPoints", testNumber_Dbl_Negative_TwoDecimalPoints),
                ("testNumber_Dbl_Negative_TwoMinuses", testNumber_Dbl_Negative_TwoMinuses),
                ("testNumber_Double_Exp_Normal", testNumber_Double_Exp_Normal),
                ("testNumber_Double_Exp_Positive", testNumber_Double_Exp_Positive),
                ("testNumber_Double_Exp_Negative", testNumber_Double_Exp_Negative),
                ("testNumber_Double_Exp_NoFrac", testNumber_Double_Exp_NoFrac),
                ("testNumber_Double_Exp_TwoEs", testNumber_Double_Exp_TwoEs),
                ("testEscape_Unicode_Normal", testEscape_Unicode_Normal),
                ("testEscape_Unicode_InvalidUnicode_MissingDigit", testEscape_Unicode_InvalidUnicode_MissingDigit),
                ("testEscape_Unicode_InvalidUnicode_MissingAllDigits", testEscape_Unicode_InvalidUnicode_MissingAllDigits),
                ("testString_Empty", testString_Empty),
                ("testString_Normal", testString_Normal),
                ("testString_Normal_WhitespaceInside", testString_Normal_WhitespaceInside),
                ("testString_StartEndWithSpaces", testString_StartEndWithSpaces),
                ("testString_Unicode_RegularChar", testString_Unicode_RegularChar),
                ("testString_Unicode_SpecialCharacter_CoolA", testString_Unicode_SpecialCharacter_CoolA),
                ("testString_Unicode_SpecialCharacter_HebrewShin", testString_Unicode_SpecialCharacter_HebrewShin),
                ("testString_Unicode_SpecialCharacter_QuarterTo", testString_Unicode_SpecialCharacter_QuarterTo),
                ("testString_Unicode_SpecialCharacter_EmojiSimple", testString_Unicode_SpecialCharacter_EmojiSimple),
                ("testString_Unicode_SpecialCharacter_EmojiComplex", testString_Unicode_SpecialCharacter_EmojiComplex),
                ("testString_SpecialCharacter_QuarterTo", testString_SpecialCharacter_QuarterTo),
                ("testString_SpecialCharacter_EmojiSimple", testString_SpecialCharacter_EmojiSimple),
                ("testString_SpecialCharacter_EmojiComplex", testString_SpecialCharacter_EmojiComplex),
                ("testObject_Empty", testObject_Empty),
                ("testObject_Example1", testObject_Example1),
                ("testDetailedError", testDetailedError),
            ]
        }
    }
#endif
