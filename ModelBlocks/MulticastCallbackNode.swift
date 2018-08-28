//
//Created by 立宣于 on 2018/8/25
//

import Foundation

public class MulticastCallbackNode<CallbackType>: ReferenceManaging {
    public typealias CallbackReference = AutoUnregisteringReference<UUID>
    public init() {}
    private var callbacks: [UUID: CallbackType] = [:]
    public func add(_ callback: CallbackType) -> CallbackReference {
        let uuid = UUID()
        callbacks[uuid] = callback
        return AutoUnregisteringReference(referenceID: uuid, referenceManager: self)
    }
    
    public func invokeEach(_ invocation: (CallbackType)->()) {
        callbacks.values.forEach{invocation($0)}
    }
    
    public func remove(with reference: Any) {
        if let ref = reference as? CallbackReference {
            remove(with: ref.referenceID)
        } else if let uuid = reference as? UUID {
            remove(with: uuid)
        } else {
            assertionFailure("[MulticastCallbackNode] Remove with unknown token type")
        }
    }
    
    private func remove(with referenceID: UUID) {
        callbacks.removeValue(forKey: referenceID)
    }
    
    var isEmpty: Bool {
        return callbacks.isEmpty
    }
}
