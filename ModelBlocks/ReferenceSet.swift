//
//Created by 立宣于 on 2019/2/22
//

import Foundation

class ReferenceSet: ReferenceManaging {
    public typealias ReferenceType = AutoUnregisteringReference<UUID>
    
    private var references: [UUID: String] = [:]
    var isEmpty: Bool {
        return references.isEmpty
    }
    func add(_ debugInfo: String = "") -> ReferenceType {
        let uuid = UUID()
        references[uuid] = debugInfo
        return AutoUnregisteringReference(referenceID: uuid, referenceManager: self)
    }
    
    func remove(with reference: Any) {
    }
}
