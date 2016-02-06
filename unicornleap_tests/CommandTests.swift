import XCTest

class CommandTests: XCTestCase {
  func testDefaults() {
    let command = Command([])

    XCTAssertFalse(command.needsHelp)
    XCTAssertFalse(command.isNotValid)
    XCTAssertEqual(command.seconds, 2.0)
    XCTAssertEqual(command.number, 1)
    XCTAssertEqual(command.unicornFile, "unicorn.png")
    XCTAssertEqual(command.sparkleFile, "sparkle.png")
  }

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

  func testHasInvalidShortFlag() {
    let args = ["-i"]
    let command = Command(args)

    XCTAssertTrue(command.isNotValid)
    XCTAssertEqual(command.invalidFlags, ["-i"])
  }

  func testHasInvalidLongFlag() {
    let args = ["--invalid"]
    let command = Command(args)

    XCTAssertTrue(command.isNotValid)
    XCTAssertEqual(command.invalidFlags, ["--invalid"])
  }

  func testProvidingShortSeconds() {
    let command = Command(["-s", "5"])
    XCTAssertFalse(command.isNotValid)
    XCTAssertEqual(command.seconds, 5.0)
  }

  func testProvidingShortSecondsWithoutAValue() {
    let command = Command(["-s"])
    XCTAssertTrue(command.isNotValid)
    XCTAssertNil(command.seconds)
  }

  func testProvidingShortSecondsWithBadValue() {
    let command = Command(["-s", "four"])
    XCTAssertTrue(command.isNotValid)
    XCTAssertNil(command.seconds)
  }

  func testProvidingLongSeconds() {
    let command = Command(["--seconds", "5"])
    XCTAssertFalse(command.isNotValid)
    XCTAssertEqual(command.seconds, 5.0)
  }

  func testProvidingLongSecondsWithoutAValue() {
    let command = Command(["--seconds"])
    XCTAssertTrue(command.isNotValid)
    XCTAssertNil(command.seconds)
  }

  func testProvidingLongSecondsWithBadValue() {
    let command = Command(["--seconds", "four"])
    XCTAssertTrue(command.isNotValid)
    XCTAssertNil(command.seconds)
  }

  func testProvidingShortAndLongSeconds() {
    let command = Command(["-s", "5", "--seconds", "6"])
    XCTAssertFalse(command.isNotValid)
    XCTAssertEqual(command.seconds, 5)
  }

  func testProvidingShortNumber() {
    let command = Command(["-n", "5"])
    XCTAssertFalse(command.isNotValid)
    XCTAssertEqual(command.number, 5)
  }

  func testProvidingShortNumberWithoutAValue() {
    let command = Command(["-n"])
    XCTAssertTrue(command.isNotValid)
    XCTAssertNil(command.number)
  }

  func testProvidingShortNumberWithBadValue() {
    let command = Command(["-n", "four"])
    XCTAssertTrue(command.isNotValid)
    XCTAssertNil(command.number)
  }

  func testProvidingLongNumber() {
    let command = Command(["--number", "5"])
    XCTAssertFalse(command.isNotValid)
    XCTAssertEqual(command.number, 5)
  }

  func testProvidingLongNumberWithoutAValue() {
    let command = Command(["--number"])
    XCTAssertTrue(command.isNotValid)
    XCTAssertNil(command.number)
  }

  func testProvidingLongNumberWithBadValue() {
    let command = Command(["--number", "four"])
    XCTAssertTrue(command.isNotValid)
    XCTAssertNil(command.number)
  }

  func testProvidingShortAndLongNumber() {
    let command = Command(["-n", "5", "--number", "6"])
    XCTAssertFalse(command.isNotValid)
    XCTAssertEqual(command.number, 5)
  }
}
