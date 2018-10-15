//
//Created by 立宣于 on 2018/8/26
//

import Foundation
public protocol ListingType {
    associatedtype ItemType
    var items: [ItemType] {get}
}

public protocol PaginatedFetchingOperationType: FailableOperationType {
    var isBegining: Bool {get}
    var nextPageFetchingOperation: PaginatedFetchingOperationType? {get}
    var retryOperation: PaginatedFetchingOperationType? {get}
}

public protocol PaginatedFetchingOperationFactoryType: AnyObject {
    associatedtype OperationType where OperationType: Operation, OperationType: PaginatedFetchingOperationType, OperationType: ListingType
    func makeInitialOperation() -> OperationType
}

public protocol FailableOperationType: AnyObject {
    var success: Bool? {get}
    var error: Error? {get}
}

open class PaginatedList<FetchingOperationFactory: PaginatedFetchingOperationFactoryType> {
    let operationFactory: FetchingOperationFactory
    let itemDidFetchCallbacks = MulticastCallbackNode<()->()>()
    let fetchingFailureCallbacks = MulticastCallbackNode<(Error?)->()>()
    public func addItemDidFetchHandler(_ handler:@escaping ()->()) -> Any {
        return itemDidFetchCallbacks.add(handler)
    }
    public func addFetchingFailureHandler(_ handler:@escaping (Error?)->()) -> Any {
        return fetchingFailureCallbacks.add(handler)
    }
    
    public private(set) var items: [FetchingOperationFactory.OperationType.ItemType] = []
    
    public init(operationFactory: FetchingOperationFactory) {
        self.operationFactory = operationFactory
    }
    
    fileprivate var currentFetchingOperation: FetchingOperationFactory.OperationType?
    fileprivate var nextPageFetchingOperation: FetchingOperationFactory.OperationType?
    public func reload() {
        if let op = currentFetchingOperation, op.isBegining {
            return
        }
        currentFetchingOperation?.cancel()
        setUpAndStart(operationFactory.makeInitialOperation())
    }
    public var isFetching: Bool {
        return currentFetchingOperation != nil
    }
    public var hasMore: Bool {
        return nextPageFetchingOperation != nil
    }
    
    private func setUpAndStart(_ operation: FetchingOperationFactory.OperationType) {
        operation.completionBlock = {[weak self] in
            self?.didFinishFetching()
        }
        currentFetchingOperation = operation
        operation.start()
    }
    
    private func didFinishFetching() {
        let op = currentFetchingOperation!
        currentFetchingOperation = nil
        nextPageFetchingOperation = op.nextPageFetchingOperation as? FetchingOperationFactory.OperationType
        if op.success == true {
            fetchDidSuccess(op)
        } else {
            fetchDidFail(op)
        }
    }
    
    private func fetchDidSuccess(_ op: FetchingOperationFactory.OperationType) {
        if op.isBegining {
            items = op.items
        } else {
            items += op.items
        }
        itemDidFetchCallbacks.invokeEach{$0()}
    }
    
    private func fetchDidFail(_ op: FetchingOperationFactory.OperationType) {
        if !op.isBegining {
            nextPageFetchingOperation = op.retryOperation as? FetchingOperationFactory.OperationType
        }
        fetchingFailureCallbacks.invokeEach{$0(op.error)}
    }
    
    public func loadMoreIfAllowed() {
        guard let next = nextPageFetchingOperation else {
            return
        }
        nextPageFetchingOperation = nil
        setUpAndStart(next)
    }
}
