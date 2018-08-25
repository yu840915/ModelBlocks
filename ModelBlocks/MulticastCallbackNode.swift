//
//Created by 立宣于 on 2018/8/25
//

import Foundation

class MulticastCallbackNode<CallbackType> {
    typealias CallbackToken = Any
    
    private var callbacks: [UUID: CallbackType] = [:]
    func add(_ callback: CallbackType) -> CallbackToken {
        let uuid = UUID()
        callbacks[uuid] = callback
        return uuid
    }
    
    func invokeEach(_ invocation: (CallbackType)->()) {
        callbacks.values.forEach{invocation($0)}
    }
    
    func remove(with token: Any) {
        if let uuid = token as? UUID {
            callbacks.removeValue(forKey: uuid)
        }
    }
    
    var isEmpty: Bool {
        return callbacks.isEmpty
    }
}
