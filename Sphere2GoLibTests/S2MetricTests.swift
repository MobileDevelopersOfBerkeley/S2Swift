//
//  S2MetricTests.swift
//  Sphere2
//

import XCTest

class S2MetricTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

  func testMetric() {
    // This is not a thorough test.
    // TODO(dsymonds): Exercise this more.
    XCTAssertEqual(Metric.minWidth.maxLevel(0.001256), 9)
  }

}
