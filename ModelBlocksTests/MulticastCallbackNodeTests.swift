//
//Created by 立宣于 on 2018/8/25
//


import XCTest
@testable import ModelBlocks

class MulticastCallbackNodeTests: XCTestCase {
    
    var node: MulticastCallbackNode<()->()>!
    override func setUp() {
        super.setUp()
        node = MulticastCallbackNode<()->()>()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAdd() {
        let token = node.add {}
        
        XCTAssertFalse(node.isEmpty)
        XCTAssertNotNil(token)
    }
    
    func testRemove() {
        let token = node.add {}
        
        node.remove(with: token)
        
        XCTAssertTrue(node.isEmpty)
    }
    
    func testInokeMultipleCallbacks() {
        var counter1 = 0
        var counter2 = 0
        
        let token1 = node.add {
            counter1 += 1
        }
        let token2 = node.add {
            counter2 += 1
        }
        
        node.invokeEach{$0()}
        
        XCTAssertEqual(counter1, 1)
        XCTAssertEqual(counter2, 1)
        XCTAssertNotNil(token1)
        XCTAssertNotNil(token2)
    }
}
