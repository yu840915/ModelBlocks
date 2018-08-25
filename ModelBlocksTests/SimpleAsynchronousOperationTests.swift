//
//  SimpleAsynchronousOperationTests.swift
//  ModelBlocksTests
//
//  Created by 立宣于 on 2018/8/25.
//

import XCTest
@testable import ModelBlocks

class SimpleAsynchronousOperationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOperationWontStartAfterCancel() {
        let op = CounterOperation()
        
        op.cancel()
        op.start()
        
        XCTAssertEqual(op.counter, 0)
    }
    
    func testCannotDoubleStart() {
        let op = CounterOperation()
        
        op.start()
        op.start()
        
        XCTAssertEqual(op.counter, 1)
    }
    
    func testDependingOperationWontStartIfDepenededNoFinished() {
        let op1 = CounterOperation()
        let op2 = CounterOperation()
        
        op2.addDependency(op1)
        op1.start()
        op2.start()
        
        XCTAssertEqual(op1.counter, 1)
        XCTAssertEqual(op2.counter, 0)
    }
    
    func testInvokeCancelHook() {
        let op = CounterOperation()
        
        op.cancel()
        
        XCTAssertEqual(op.cancelCounter, 1)
    }
    
    func testPreventDoubleCancel() {
        let op = CounterOperation()
        
        op.cancel()
        op.cancel()

        XCTAssertEqual(op.cancelCounter, 1)
    }
}

fileprivate extension SimpleAsynchronousOperationTests {
    class CounterOperation: SimpleAsynchronousOperation {
        private(set) var counter = 0
        private(set) var cancelCounter = 0
        override func main() {
            counter += 1
        }
        
        override func onCancel() {
            cancelCounter += 1
        }
    }
    
    class NormalFinishOperation: SimpleAsynchronousOperation {
        override func main() {
            finish()
        }
    }
}
