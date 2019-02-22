//
//Created by 立宣于 on 2019/2/22
//

import XCTest
@testable import ModelBlocks

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

}
