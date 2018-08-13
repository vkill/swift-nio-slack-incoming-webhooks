import XCTest

import NIOSlackIncomingWebhooksTests

var tests = [XCTestCaseEntry]()
tests += NIOSlackIncomingWebhooksTests.allTests()
XCTMain(tests)