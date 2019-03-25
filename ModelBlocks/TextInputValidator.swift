//
//Created by 立宣于 on 2019/3/25
//

import Foundation

open class TextInputValidator {
    public init() {}
    
    open func validate(_ input: String) throws {
    }
}

open class CompoundValidator: TextInputValidator {
    let validators: [TextInputValidator]
    let multipleErrorTitle: String
    public init(_ validators: [TextInputValidator], multipleErrorTitle: String = "Multiple Errors Occurred") {
        self.validators = validators
        self.multipleErrorTitle = multipleErrorTitle
    }
    
    open override func validate(_ input: String) throws {
        var errors = [Error]()
        validators.forEach { (validator) in
            do {
                try validator.validate(input)
            } catch let e {
                errors.append(e)
            }
        }
        if !errors.isEmpty {
            if errors.count == 1, let e = errors.first {
                throw e
            }
            throw InputError(localizedDescription: multipleErrorTitle, errors: errors)
        }
    }
}

open class AndValidator: CompoundValidator {
    open override func validate(_ input: String) throws {
        try validators.forEach{try $0.validate(input)}
    }
}

open class InputError: NSError {
    static let MBUnderlyingErrorsKey = "MBUnderlyingErrorsKey"
    public init(localizedDescription: String, errors: [Error] = [], domain: String = Bundle.main.bundleIdentifier ?? "framework.modelblocks", code: Int = 400) {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: localizedDescription]
        if !errors.isEmpty {
            userInfo[InputError.MBUnderlyingErrorsKey] = errors
        }
        super.init(domain: domain, code: code, userInfo: userInfo)
    }
    
    public var underlyingErrors: [Error]? {
        return userInfo[InputError.MBUnderlyingErrorsKey] as? [Error]
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
