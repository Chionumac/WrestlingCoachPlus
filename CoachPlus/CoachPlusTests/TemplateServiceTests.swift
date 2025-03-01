import XCTest
@testable import CoachPlus

final class TemplateServiceTests: XCTestCase {
    var service: MockTemplateService!
    
    override func setUp() {
        super.setUp()
        service = MockTemplateService()
    }
    
    override func tearDown() {
        service.reset()
        service = nil
        super.tearDown()
    }
    
    // MARK: - Basic CRUD Tests
    
    func testSaveTemplate() throws {
        // Given
        let template = PracticeTemplate(
            name: "Test Template",
            sections: ["Warm up", "Main set"],
            intensity: 0.5,
            liveTimeMinutes: 30,
            includesLift: true,
            practiceTime: Date()
        )
        
        // When
        try service.save(template)
        
        // Then
        XCTAssertTrue(service.saveWasCalled)
        let templates = service.load()
        XCTAssertEqual(templates.count, 1)
        XCTAssertEqual(templates.first?.name, "Test Template")
    }
    
    func testLoadTemplates() {
        // Given
        let template1 = PracticeTemplate(
            name: "Template 1",
            sections: ["Section 1"],
            intensity: 0.5
        )
        let template2 = PracticeTemplate(
            name: "Template 2",
            sections: ["Section 2"],
            intensity: 0.7
        )
        
        try? service.save(template1)
        try? service.save(template2)
        
        // When
        let templates = service.load()
        
        // Then
        XCTAssertTrue(service.loadWasCalled)
        XCTAssertEqual(templates.count, 2)
    }
    
    func testDeleteTemplate() {
        // Given
        let template = PracticeTemplate(
            name: "Test Template",
            sections: ["Test Section"],
            intensity: 0.5
        )
        try? service.save(template)
        
        // When
        service.delete(template)
        
        // Then
        XCTAssertTrue(service.deleteWasCalled)
        let templates = service.load()
        XCTAssertTrue(templates.isEmpty)
    }
    
    // MARK: - Validation Tests
    
    func testTemplateValidation() {
        // Test invalid cases
        let invalidTemplates: [(PracticeTemplate, String)] = [
            (PracticeTemplate(
                name: "",
                sections: ["Test"],
                intensity: 0.5
            ), "Empty name"),
            
            (PracticeTemplate(
                name: "Test",
                sections: [],
                intensity: 0.5
            ), "Empty sections"),
            
            (PracticeTemplate(
                name: "Test",
                sections: [""],
                intensity: -0.1
            ), "Invalid intensity")
        ]
        
        for (template, description) in invalidTemplates {
            XCTAssertFalse(service.validate(template), description)
        }
        
        // Test valid case
        let validTemplate = PracticeTemplate(
            name: "Valid Template",
            sections: ["Valid Section"],
            intensity: 0.5
        )
        XCTAssertTrue(service.validate(validTemplate))
    }
    
    // MARK: - Error Handling Tests
    
    func testSaveFailure() {
        // Given
        service.shouldFail = true
        let template = PracticeTemplate(
            name: "Test Template",
            sections: ["Test Section"],
            intensity: 0.5
        )
        
        // When/Then
        XCTAssertThrowsError(try service.save(template)) { error in
            XCTAssertEqual(error as? TemplateServiceError, .saveFailed)
        }
    }
    
    func testDeleteAllFailure() {
        // Given
        service.shouldFail = true
        
        // When/Then
        XCTAssertThrowsError(try service.deleteAll()) { error in
            XCTAssertEqual(error as? TemplateServiceError, .deleteFailed)
        }
    }
} 