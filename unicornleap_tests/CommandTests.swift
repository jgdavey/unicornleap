import XCTest

class CommandTests: XCTestCase {
  func testDefaults() {
    let command = Command([])

    XCTAssertFalse(command.needsHelp)
    XCTAssertFalse(command.isNotValid)
    XCTAssertFalse(command.verboseOutput)
    XCTAssertEqual(command.seconds, 2.0)
    XCTAssertEqual(command.number, 1)
    XCTAssertEqual(command.unicornFile, "unicorn.png")
    XCTAssertEqual(command.sparkleFile, "sparkle.png")
  }

  func testNeedsHelp() {
    for flag in ["-h", "--help"] {
      let command = Command([flag])
      XCTAssertFalse(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertTrue(command.needsHelp, "for flag: '\(flag)'")
    }
  }

  func testWantsVerboseOutput() {
    for flag in ["-v", "--verbose"] {
      let command = Command([flag])
      XCTAssertFalse(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertTrue(command.verboseOutput, "for flag: '\(flag)'")
    }
  }

  func testHasInvalidFlags() {
    for flag in ["-i", "--invalid"] {
      let command = Command([flag])
      XCTAssertTrue(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertEqual(command.invalidFlags, [flag], "for flag: '\(flag)'")
    }
  }

  func testProvidingSeconds() {
    for flag in ["-s", "--seconds"] {
      let command = Command([flag, "5"])
      XCTAssertFalse(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertEqual(command.seconds, 5.0, "for flag: '\(flag)'")
    }
  }

  func testProvidingSecondsWithoutAValue() {
    for flag in ["-s", "--seconds"] {
      let command = Command([flag])
      XCTAssertTrue(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertNil(command.seconds, "for flag: '\(flag)'")
    }
  }

  func testProvidingSecondsWithBadValue() {
    for flag in ["-s", "--seconds"] {
      let command = Command([flag, "four"])
      XCTAssertTrue(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertNil(command.seconds, "for flag: '\(flag)'")
    }
  }

  func testProvidingShortAndLongSeconds() {
    let command = Command(["-s", "5", "--seconds", "6"])
    XCTAssertFalse(command.isNotValid)
    XCTAssertEqual(command.seconds, 5)
  }

  func testProvidingNumber() {
    for flag in ["-n", "--number"] {
      let command = Command([flag, "5"])
      XCTAssertFalse(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertEqual(command.number, 5, "for flag: '\(flag)'")
    }
  }

  func testProvidingNumberWithoutAValue() {
    for flag in ["-n", "--number"] {
      let command = Command([flag])
      XCTAssertTrue(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertNil(command.number, "for flag: '\(flag)'")
    }
  }

  func testProvidingNumberWithBadValue() {
    for flag in ["-n", "--number"] {
      let command = Command([flag, "four"])
      XCTAssertTrue(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertNil(command.number, "for flag: '\(flag)'")
    }
  }

  func testProvidingShortAndLongNumber() {
    let command = Command(["-n", "5", "--number", "6"])
    XCTAssertFalse(command.isNotValid)
    XCTAssertEqual(command.number, 5)
  }
}
