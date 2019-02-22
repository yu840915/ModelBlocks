//
//Created by 立宣于 on 2019/2/22
//

import Foundation

public class ReferenceSet: ReferenceManaging {
    public typealias ReferenceType = AutoUnregisteringReference<UUID>
    
    public init() {}
    fileprivate var references: [UUID: String] = [:] {
        didSet {
            isEmpty = references.isEmpty
        }
    }
    public let isEmptyDidChangeObservers = MulticastCallbackNode<(Bool)->()>()
    public private(set) var isEmpty: Bool = true {
        didSet {
            if oldValue != isEmpty {
                isEmptyDidChangeObservers.invokeEach{$0(isEmpty)}
            }
        }
    }
    public func add(_ debugInfo: String = "") -> ReferenceType {
        let uuid = UUID()
        references[uuid] = debugInfo
        return AutoUnregisteringReference(referenceID: uuid, referenceManager: self)
    }
    
    public func remove(with reference: Any) {
        if let ref = reference as? ReferenceType {
            remove(with: ref.referenceID)
        } else if let uuid = reference as? UUID {
            remove(with: uuid)
        } else {
            assertionFailure("[ReferenceSet] Remove with unknown token type")
        }
    }

    private func remove(with referenceID: UUID) {
        references.removeValue(forKey: referenceID)
    }
}

extension ReferenceSet: CustomDebugStringConvertible {
    public var debugDescription: String {
        var value = "[ReferenceSet]{Count: \(references.count)"
        let infos = references.values.filter{!$0.isEmpty}
        if !infos.isEmpty {
            value += ", infos: [\(infos.joined(separator: ", "))]"
        }
        return  value + "}"
    }
}
