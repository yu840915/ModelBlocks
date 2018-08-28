//
//Created by 立宣于 on 2018/8/25
//

import Foundation

protocol ReferenceManaging: AnyObject{
    func remove(with reference: Any)
}

public class AutoUnregisteringReference<ReferenceID> {
    let referenceID: ReferenceID
    let referenceManager: ReferenceManaging?
    public init(referenceID: ReferenceID, referenceManager: ReferenceManaging) {
        self.referenceID = referenceID
        self.referenceManager = referenceManager
    }
    
    public func unregister() {
        referenceManager?.remove(with: self)
    }
    
    deinit {
        unregister()
    }
}
