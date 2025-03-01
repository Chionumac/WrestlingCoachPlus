import XCTest
@testable import CoachPlus

final class PracticeServiceTests: XCTestCase {
    var service: MockPracticeService!
    
    override func setUp() {
        super.setUp()
        service = MockPracticeService()
    }
    
    override func tearDown() {
        service.reset()
        service = nil
        super.tearDown()
    }
    
    // MARK: - Basic CRUD Tests
    
    func testSavePractice() throws {
        // Given
        let practice = Practice(
            date: Date(),
            type: .practice,
            sections: ["Test Practice"],
            intensity: 0.5,
            isFromTemplate: false
        )
        
        // When
        try service.save(practice)
        
        // Then
        XCTAssertTrue(service.saveWasCalled)
        let savedPractice = service.getPractice(for: practice.date)
        XCTAssertEqual(savedPractice?.sections, ["Test Practice"])
    }
    
    func testLoadPractices() {
        // Given
        let practice1 = Practice(
            date: Date(),
            type: .practice,
            sections: ["Practice 1"],
            intensity: 0.5,
            isFromTemplate: false
        )
        let practice2 = Practice(
            date: Date().addingTimeInterval(86400), // Next day
            type: .practice,
            sections: ["Practice 2"],
            intensity: 0.7,
            isFromTemplate: false
        )
        
        try? service.save(practice1)
        try? service.save(practice2)
        
        // When
        let loadedPractices = service.load()
        
        // Then
        XCTAssertTrue(service.loadWasCalled)
        XCTAssertEqual(loadedPractices.count, 2)
    }
    
    func testDeletePractice() {
        // Given
        let date = Date()
        let practice = Practice(
            date: date,
            type: .practice,
            sections: ["Test Practice"],
            intensity: 0.5,
            isFromTemplate: false
        )
        try? service.save(practice)
        
        // When
        service.delete(for: date)
        
        // Then
        XCTAssertTrue(service.deleteWasCalled)
        XCTAssertNil(service.getPractice(for: date))
    }
    
    func testGetPracticeForDate() {
        // Given
        let date = Date()
        let practice = Practice(
            date: date,
            type: .practice,
            sections: ["Test Practice"],
            intensity: 0.5,
            isFromTemplate: false
        )
        try? service.save(practice)
        
        // When
        let retrieved = service.getPractice(for: date)
        
        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.sections, ["Test Practice"])
    }
    
    // MARK: - Error Handling Tests
    
    func testSaveFailure() {
        // Given
        service.shouldFail = true
        let practice = Practice(
            date: Date(),
            type: .practice,
            sections: ["Test Practice"],
            intensity: 0.5,
            isFromTemplate: false
        )
        
        // When/Then
        XCTAssertThrowsError(try service.save(practice)) { error in
            XCTAssertEqual(error as? PracticeServiceError, .saveFailed)
        }
    }
    
    func testSaveMultipleFailure() {
        // Given
        service.shouldFail = true
        let practices = [
            Practice(
                date: Date(),
                type: .practice,
                sections: ["Practice 1"],
                intensity: 0.5,
                isFromTemplate: false
            ),
            Practice(
                date: Date().addingTimeInterval(86400),
                type: .practice,
                sections: ["Practice 2"],
                intensity: 0.7,
                isFromTemplate: false
            )
        ]
        
        // When/Then
        XCTAssertThrowsError(try service.saveMultiple(practices)) { error in
            XCTAssertEqual(error as? PracticeServiceError, .saveFailed)
        }
    }
    
    func testValidation() {
        // Test invalid cases
        let invalidPractices: [(Practice, String)] = [
            (Practice(
                date: Date(),
                type: .practice,
                sections: [],
                intensity: 0.5,
                isFromTemplate: false
            ), "Empty sections"),
            
            (Practice(
                date: Date(),
                type: .practice,
                sections: [""],
                intensity: -0.1,
                isFromTemplate: false
            ), "Invalid intensity"),
            
            (Practice(
                date: Date(),
                type: .competition,
                sections: [""],
                intensity: 0.5,
                isFromTemplate: false
            ), "Empty competition name")
        ]
        
        for (practice, description) in invalidPractices {
            XCTAssertFalse(service.validate(practice), description)
        }
        
        // Test valid case
        let validPractice = Practice(
            date: Date(),
            type: .practice,
            sections: ["Valid Practice"],
            intensity: 0.5,
            isFromTemplate: false
        )
        XCTAssertTrue(service.validate(validPractice))
    }
    
    func testDeleteAllFailure() {
        // Given
        service.shouldFail = true
        
        // When/Then
        XCTAssertThrowsError(try service.deleteAll()) { error in
            XCTAssertEqual(error as? PracticeServiceError, .deleteFailed)
        }
    }
} 