
import XCTest
import YAJL

fileprivate let n = 5

class ParserBenchmarks: XCTestCase {


  func testParseLargeJson() {

    let data = loadFixture("large")

    measure {
      for _ in 0..<n {
        _ = try! JSONParser.parse(data)
      }
    }
  }

  func testParseLargeMinJson() {

    let data = loadFixture("large_min")

    measure {
      for _ in 0..<n {
        _ = try! JSONParser.parse(data)
      }
    }
  }

  func testParseInsaneJson() {

    let data = loadFixture("insane")

    measure {
      _ = try! JSONParser.parse(data)
    }
  }

}

#if os(Linux)
extension ParserBenchmarks: XCTestCaseProvider {

  var allTests : [(String, () throws -> Void)] {
    return [
      ("testParseLargeJson", testParseLargeJson),
      ("testParseLargeMinJson", testParseLargeMinJson),
    ]
  }
}
#endif
