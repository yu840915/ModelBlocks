//
//Created by 立宣于 on 2019/3/25
//

import XCTest
import ModelBlocks

class CompoundValidatorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testThrowOnInputError() {
        let validator = CompoundValidator([AlwaysThrowValidator()])
        XCTAssertThrowsError(try validator.validate("hello"))
    }
    
    func testCollectErrors() {
        let validator = CompoundValidator([AlwaysThrowValidator(), AlwaysThrowValidator()])
        do {
            try validator.validate("hello")
            XCTFail("Expect throws here")
        } catch let error as InputError {
            XCTAssertEqual(error.underlyingErrors?.count, 2)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCollectOneError() {
        let validator = CompoundValidator([AlwaysThrowValidator()])
        do {
            try validator.validate("hello")
            XCTFail("Expect throws here")
        } catch let error as InputError {
            XCTAssertNil(error.underlyingErrors)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testNoThrow() {
        let validator = CompoundValidator([TextInputValidator(), TextInputValidator()])
        XCTAssertNoThrow(try validator.validate("hello"))
    }
    
    func testShortCircuitWithAndValidation() {
        let validator = AndValidator([AlwaysThrowValidator(), AlwaysThrowValidator()])
        do {
            try validator.validate("hello")
            XCTFail("Expect throws here")
        } catch let error as InputError {
            XCTAssertNil(error.underlyingErrors)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testNotThrowIfOnePassesWithOrValidation() {
        let validator1 = OrValidator([TextInputValidator(), AlwaysThrowValidator(), AlwaysThrowValidator()])
        XCTAssertNoThrow(try validator1.validate("hello"))

        let validator2 = OrValidator([AlwaysThrowValidator(), TextInputValidator(), AlwaysThrowValidator()])
        XCTAssertNoThrow(try validator2.validate("hello"))

        let validator3 = OrValidator([AlwaysThrowValidator(), AlwaysThrowValidator(), TextInputValidator()])
        XCTAssertNoThrow(try validator3.validate("hello"))
    }
    
    func testThrowsIfAllFailedWithOrValidation() {
        let validator = OrValidator([AlwaysThrowValidator(), AlwaysThrowValidator()])
        XCTAssertThrowsError(try validator.validate("hello"))
    }
}

extension CompoundValidatorTests {
    class AlwaysThrowValidator: TextInputValidator {
        override func validate(_ input: String) throws {
            throw InputError(localizedDescription: "failed")
        }
    }
}
