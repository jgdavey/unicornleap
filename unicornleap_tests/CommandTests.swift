import XCTest

class CommandTests: XCTestCase {
  func testNeedsHelp() {
    let args = ["-h"]
    let command = Command(args)

    XCTAssertTrue(command.needsHelp)
  }

  func testNeedsHelpLong() {
    let args = ["--help"]
    let command = Command(args)

    XCTAssertTrue(command.needsHelp)
  }

  func testNeedsNoHelp() {
    let args = [""]
    let command = Command(args)

    XCTAssertFalse(command.needsHelp)
  }

  func testHasInvalidShortFlag() {
    let args = ["-i"]
    let command = Command(args)

    XCTAssertTrue(command.isNotValid)
  }

  func testHasInvalidLongFlag() {
    let args = ["--invalid"]
    let command = Command(args)

    XCTAssertTrue(command.isNotValid)
  }
}
