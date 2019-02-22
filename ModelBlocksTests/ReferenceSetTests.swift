//
//Created by 立宣于 on 2019/2/22
//

import XCTest
import ModelBlocks

class ReferenceSetTests: XCTestCase {
    
    let referenceSet = ReferenceSet()
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAdd() {
        let registration: Any? = referenceSet.add()
        
        XCTAssertFalse(referenceSet.isEmpty)
        XCTAssertNotNil(registration)
    }
    
    func testAutoRemove() {
        var registration: Any? = referenceSet.add()
        
        XCTAssertFalse(referenceSet.isEmpty)
        registration = nil
        XCTAssertTrue(referenceSet.isEmpty)
    }
    
    func testNotifyOnBecomingNonEmpty() {
        var counter = 0
        var isEmpty = true
        let observer = referenceSet.isEmptyDidChangeObservers.add { (val) in
            isEmpty = val
            counter += 1
        }
        
        var registration: Any? = referenceSet.add()
        
        XCTAssertFalse(isEmpty)
        XCTAssertEqual(counter, 1)
    }
    
    func testNotifyOnBecomingEmpty() {
        var counter = 0
        var isEmpty = true
        let observer = referenceSet.isEmptyDidChangeObservers.add { (val) in
            isEmpty = val
            counter += 1
        }
        
        var registration: Any? = referenceSet.add()
        registration = nil
        
        XCTAssertTrue(isEmpty)
        XCTAssertEqual(counter, 2)
    }
    
    func testNotNotifyForMultipleReferences() {
        var counter = 0
        let observer = referenceSet.isEmptyDidChangeObservers.add { (_) in
            counter += 1
        }

        var registration1: Any? = referenceSet.add()
        var registration2: Any? = referenceSet.add()
        registration1 = nil

        XCTAssertEqual(counter, 1)
    }
}
