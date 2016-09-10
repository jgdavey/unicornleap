import XCTest

class CommandTests: XCTestCase {
  func testDefaults() {
    let command = Command([])

    XCTAssertFalse(command.needsHelp)
    XCTAssertFalse(command.isNotValid)
    XCTAssertFalse(command.verboseOutput)
    XCTAssertEqual(command.seconds, 2.0)
    XCTAssertEqual(command.number, 1)
    XCTAssertEqual(command.eccentricity, 1.0)
    XCTAssertTrue(command.unicornFile!.rangeOfString("unicorn.png") != nil)
    XCTAssertTrue(command.sparkleFile!.rangeOfString("sparkle.png") != nil)
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

  func testWantsHerdMode() {
    for flag in ["-H", "--herd"] {
      let command = Command([flag])
      XCTAssertFalse(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertTrue(command.herd, "for flag: '\(flag)'")
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

  func testProvidingeccentricity() {
    for flag in ["-e", "--eccentricity"] {
      let command = Command([flag, "5"])
      XCTAssertFalse(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertEqual(command.eccentricity, 5.0, "for flag: '\(flag)'")
    }
  }

  func testProvidingeccentricityWithoutAValue() {
    for flag in ["-e", "--eccentricity"] {
      let command = Command([flag])
      XCTAssertTrue(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertNil(command.eccentricity, "for flag: '\(flag)'")
    }
  }

  func testProvidingeccentricityWithBadValue() {
    for flag in ["-e", "--eccentricity"] {
      let command = Command([flag, "four"])
      XCTAssertTrue(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertNil(command.eccentricity, "for flag: '\(flag)'")
    }
  }

  func testProvidingShortAndLongeccentricity() {
    let command = Command(["-e", "5", "--eccentricity", "6"])
    XCTAssertFalse(command.isNotValid)
    XCTAssertEqual(command.eccentricity, 5)
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

  func testProvidingUnicornFile() {
    for flag in ["-u", "--unicorn"] {
      let command = Command([flag, "hippo.png"])
      XCTAssertFalse(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertEqual(command.unicornFile, "hippo.png", "for flag: '\(flag)'")
    }
  }

  func testProvidingUnicornFileWithoutAValue() {
    for flag in ["-u", "--unicorn"] {
      let command = Command([flag])
      XCTAssertTrue(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertNil(command.unicornFile, "for flag: '\(flag)'")
    }
  }

  func testProvidingShortAndLongUnicornFile() {
    let command = Command(["-u", "hippo.png", "--unicorn", "bat.png"])
    XCTAssertFalse(command.isNotValid)
    XCTAssertEqual(command.unicornFile, "hippo.png")
  }

  func testProvidingSparkleFile() {
    for flag in ["-k", "--sparkle"] {
      let command = Command([flag, "poof.png"])
      XCTAssertFalse(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertEqual(command.sparkleFile, "poof.png", "for flag: '\(flag)'")
    }
  }

  func testProvidingSparkleFileWithoutAValue() {
    for flag in ["-k", "--sparkle"] {
      let command = Command([flag])
      XCTAssertTrue(command.isNotValid, "for flag: '\(flag)'")
      XCTAssertNil(command.sparkleFile, "for flag: '\(flag)'")
    }
  }

  func testProvidingShortAndLongSparkleFile() {
    let command = Command(["-k", "poof.png", "--sparkle", "blood.png"])
    XCTAssertFalse(command.isNotValid)
    XCTAssertEqual(command.sparkleFile, "poof.png")
  }
}
