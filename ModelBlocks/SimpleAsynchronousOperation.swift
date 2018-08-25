//
//  SimpleAsynchronousOperation.swift
//  ModelBlocks
//
//  Created by 立宣于 on 2018/8/25.
//

import Foundation

open class SimpleAsynchronousOperation: Operation {
    
    public final override var isAsynchronous: Bool {
        return true
    }
    
    fileprivate var _executing = false
    public final override var isExecuting : Bool {
        return isCancelled ? false : _executing
    }
    
    fileprivate var _finished = false
    public final override var isFinished : Bool {
        return isCancelled ? true : _finished
    }
    
    fileprivate let executingKey = "executing"
    fileprivate let finishedKey = "finished"
    open override func start() {
        guard isReady && !isFinished && !isExecuting else {
            return
        }
        willChangeValue(forKey: executingKey)
        _executing = true
        didChangeValue(forKey: executingKey)
        main()
    }
    
    open override func main() {
        finish()
    }
    
    final public override func cancel() {
        guard !isCancelled else {
            return
        }
        super.cancel()
        onCancel()
    }
    
    open func onCancel() {
    }
    
    public final func finish() {
        guard !isCancelled else {
            return
        }
        willChangeValue(forKey: finishedKey)
        willChangeValue(forKey: executingKey)
        _executing = false
        _finished = true
        didChangeValue(forKey: executingKey)
        didChangeValue(forKey: finishedKey)
        completionBlock?()
        completionBlock = nil
    }
    
}
