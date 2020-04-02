import XCTest

import sharedTests

var tests = [XCTestCaseEntry]()
tests += sharedTests.allTests()
XCTMain(tests)
