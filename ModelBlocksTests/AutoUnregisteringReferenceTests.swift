//
//Created by 立宣于 on 2018/8/25
//

import XCTest
@testable import ModelBlocks

class AutoUnregisteringReferenceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAutoUnregister() {
        let manager = FakeManager()
        var ref: Any? = AutoUnregisteringReference<String>(referenceID: "123", referenceManager: manager)
        
        XCTAssertNotNil(ref)
        ref = nil
        
        XCTAssertEqual(manager.counter, 1)
    }
    
}

extension AutoUnregisteringReferenceTests {
    class FakeManager: ReferenceManaging {
        private(set) var counter = 0
        func remove(with reference: Any) {
            counter += 1
        }
    }
}
