//
//Created by 立宣于 on 2018/8/26
//

import XCTest
@testable import ModelBlocks

class PaginatedListTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCreateOperationFromFactoryWhenReload() {
        let factory = AlwaysSucceedFetchingOperationFactory()
        let list = PaginatedList(operationFactory: factory)
        list.reload()
        XCTAssertEqual(factory.counter, 1)
    }
    
    func testUpdateItemsAfterReload() {
        let list = PaginatedList(operationFactory: AlwaysSucceedFetchingOperationFactory())
        XCTAssertTrue(list.items.isEmpty)
        list.reload()
        XCTAssertEqual(list.items, [0])
    }
    
    func testCallbackOnReloadFinish() {
        let  list = PaginatedList(operationFactory: AlwaysSucceedFetchingOperationFactory())
        var counter = 0
        list.didFetchItems = {
            counter += 1
        }
        list.reload()
        XCTAssertEqual(counter, 1)
    }
    
    func testLoadMore() {
        let  list = PaginatedList(operationFactory: AlwaysSucceedFetchingOperationFactory())
        list.reload()
        list.loadMoreIfAllowed()
        XCTAssertEqual(list.items, [0, 1])
    }
    
    func testReloadAfterLoadMore() {
        let  list = PaginatedList(operationFactory: AlwaysSucceedFetchingOperationFactory())
        list.reload()
        list.loadMoreIfAllowed()
        list.reload()
        XCTAssertEqual(list.items, [0])
    }
    
    func testIsFetching() {
        let  list = PaginatedList(operationFactory: NeverEndFetchingOperationFactory())
        XCTAssertFalse(list.isFetching)
        list.reload()
        XCTAssertTrue(list.isFetching)
    }
    
    func testHasMore() {
        let  list = PaginatedList(operationFactory: AlwaysSucceedFetchingOperationFactory())
        XCTAssertFalse(list.hasMore) //Has more is meaningful after we get data
        list.reload()
        XCTAssertTrue(list.hasMore)
    }
    
    func testCallbackOnFailure() {
        let  list = PaginatedList(operationFactory: AlwaysFailFetchingOperationFactory())
        var counter = 0
        var error: Error?
        list.didFailFetching = { err in
            counter += 1
            error = err
        }
        list.reload()
        XCTAssertEqual(counter, 1)
        XCTAssertNotNil(error)
        XCTAssertTrue(list.items.isEmpty)
    }
}

extension PaginatedListTests {
    class AlwaysSucceedFetchingOperationFactory: PaginatedFetchingOperationFactoryType {
        var counter: Int = 0
        func makeInitialOperation() -> FakeOperation {
            counter += 1
            let op = FakeOperation()
            return op
        }
        
        class FakeOperation: Operation, PaginatedFetchingOperationType, ListingType {
            var counter: Int = 0
            var error: Error?
            var success: Bool? = true
            var isBegining: Bool = true
            var retryOperation: PaginatedFetchingOperationType? {
                let op = FakeOperation()
                op.counter = counter
                return op
            }
            var nextPageFetchingOperation: PaginatedFetchingOperationType? {
                let op = FakeOperation()
                op.counter = counter + 1
                op.isBegining = false
                return op
            }
            var items: [Int] {
                return [counter]
            }
            override func main() {
                //fake finish, preventing completionBlock being executed on other thread
                completionBlock?()
                completionBlock = nil
            }
        }
    }
    
    class NeverEndFetchingOperationFactory: PaginatedFetchingOperationFactoryType {
        var counter: Int = 0
        func makeInitialOperation() -> FakeOperation {
            counter += 1
            return FakeOperation()
        }
        
        class FakeOperation: SimpleAsynchronousOperation, PaginatedFetchingOperationType, ListingType {
            var items: [Int] = []
            var error: Error?
            var success: Bool?
            var isBegining: Bool = true
            var retryOperation: PaginatedFetchingOperationType?
            var nextPageFetchingOperation: PaginatedFetchingOperationType?
            override func main() {
            }
        }
    }
    
    class AlwaysFailFetchingOperationFactory: PaginatedFetchingOperationFactoryType {
        var counter: Int = 0
        func makeInitialOperation() -> FakeOperation {
            counter += 1
            let op = FakeOperation()
            return op
        }
        
        class FakeOperation: Operation, PaginatedFetchingOperationType, ListingType {
            var counter: Int = 0
            var error: Error? = NSError(domain: "", code: -1, userInfo: nil)
            var success: Bool? = false
            var isBegining: Bool = true
            var retryOperation: PaginatedFetchingOperationType?
            var nextPageFetchingOperation: PaginatedFetchingOperationType?
            var items: [Int] = []
            override func main() {
                //fake finish, preventing completionBlock being executed on other thread
                completionBlock?()
                completionBlock = nil
            }
        }
    }
}
