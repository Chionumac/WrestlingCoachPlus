import XCTest
@testable import CoachPlus

final class PracticeManagerTests: XCTestCase {
    var mockService: MockPracticeService!
    var manager: PracticeManager!
    
    override func setUp() {
        super.setUp()
        mockService = MockPracticeService()
        manager = PracticeManager(service: mockService)
    }
    
    override func tearDown() {
        mockService.reset()
        mockService = nil
        manager = nil
        super.tearDown()
    }
    
    func testCreatePractice() throws {
        // Given
        let date = Date()
        let time = Date()
        let sections = ["Test Section"]
        
        // When
        let practice = try manager.createPractice(
            date: date,
            time: time,
            type: .practice,
            sections: sections,
            intensity: 0.5
        )
        
        // Then
        XCTAssertTrue(mockService.saveWasCalled)
        XCTAssertEqual(practice.sections, sections)
    }
    
    func testCreatePracticeWithEmptySections() {
        // Given
        let date = Date()
        let time = Date()
        let sections: [String] = []
        
        // When/Then
        XCTAssertThrowsError(try manager.createPractice(
            date: date,
            time: time,
            type: .practice,
            sections: sections,
            intensity: 0.5
        )) { error in
            XCTAssertEqual(error as? PracticeError, .invalidSections)
        }
    }
    
    func testCreateRecurringPractices() throws {
        // Given
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
        let sections = ["Test Section"]
        
        // When
        try manager.createRecurringPractices(
            startDate: startDate,
            endDate: endDate,
            pattern: .daily,
            time: Date(),
            type: .practice,
            sections: sections,
            intensity: 0.5,
            includesLift: false,
            liveTimeMinutes: 0
        )
        
        // Then
        let practices = mockService.load()
        XCTAssertEqual(practices.count, 8) // 8 days including start and end
    }
    
    func testServiceFailure() {
        // Given
        mockService.shouldFail = true
        
        // When/Then
        XCTAssertThrowsError(try manager.createPractice(
            date: Date(),
            time: Date(),
            type: .practice,
            sections: ["Test"],
            intensity: 0.5
        ))
    }
    
    func testDeletePractice() {
        // Given
        let date = Date()
        let practice = Practice(
            date: date,
            type: .practice,
            sections: ["Test"],
            intensity: 0.5,
            isFromTemplate: false
        )
        try? mockService.save(practice)
        
        // When
        manager.deletePractice(for: date)
        
        // Then
        XCTAssertTrue(mockService.deleteWasCalled)
        XCTAssertNil(manager.practiceForDate(date))
    }
    
    func testGetPracticeForDate() {
        // Given
        let date = Date()
        let practice = Practice(
            date: date,
            type: .practice,
            sections: ["Test"],
            intensity: 0.5,
            isFromTemplate: false
        )
        try? mockService.save(practice)
        
        // When
        let retrieved = manager.practiceForDate(date)
        
        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.sections, ["Test"])
    }
    
    func testCombineDateAndTime() {
        // Given
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2024, month: 3, day: 15))!
        let time = calendar.date(from: DateComponents(hour: 14, minute: 30))!
        
        // When
        let combined = manager.combineDateAndTime(date: date, time: time)
        
        // Then
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: combined)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 3)
        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.hour, 14)
        XCTAssertEqual(components.minute, 30)
    }
    
    func testCreateRecurringPracticesWithInvalidDates() {
        // Given
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: -1, to: startDate)!
        
        // When/Then
        XCTAssertThrowsError(try manager.createRecurringPractices(
            startDate: startDate,
            endDate: endDate,
            pattern: .daily,
            time: Date(),
            type: .practice,
            sections: ["Test"],
            intensity: 0.5,
            includesLift: false,
            liveTimeMinutes: 0
        ))
    }
    
    func testOverwriteExistingPractice() throws {
        // Given
        let date = Date()
        let originalPractice = Practice(
            date: date,
            type: .practice,
            sections: ["Original Practice"],
            intensity: 0.5,
            isFromTemplate: false
        )
        try mockService.save(originalPractice)
        
        // When
        let newPractice = try manager.createPractice(
            date: date,
            time: date,
            type: .practice,
            sections: ["Updated Practice"],
            intensity: 0.7
        )
        
        // Then
        let retrieved = manager.practiceForDate(date)
        XCTAssertEqual(retrieved?.sections, ["Updated Practice"])
        XCTAssertEqual(retrieved?.intensity, 0.7)
    }
    
    func testSaveMultipleRecurringPractices() throws {
        // Given
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
        
        // When - Create first set
        try manager.createRecurringPractices(
            startDate: startDate,
            endDate: endDate,
            pattern: .daily,
            time: Date(),
            type: .practice,
            sections: ["First Set"],
            intensity: 0.5,
            includesLift: false,
            liveTimeMinutes: 0
        )
        
        // Create overlapping set
        try manager.createRecurringPractices(
            startDate: startDate,
            endDate: endDate,
            pattern: .daily,
            time: Date(),
            type: .practice,
            sections: ["Second Set"],
            intensity: 0.7,
            includesLift: true,
            liveTimeMinutes: 30
        )
        
        // Then
        let practices = mockService.load()
        XCTAssertEqual(practices.count, 8) // Should still be 8 as they overlap
        XCTAssertEqual(practices.first?.sections, ["Second Set"]) // Should have latest values
        XCTAssertEqual(practices.first?.intensity, 0.7)
        XCTAssertTrue(practices.first?.includesLift ?? false)
    }
    
    func testInvalidPracticeTypes() {
        // Test rest day with sections
        XCTAssertThrowsError(try manager.createPractice(
            date: Date(),
            time: Date(),
            type: .rest,
            sections: ["Should not have sections"],
            intensity: 0.5
        ))
        
        // Test competition without name
        XCTAssertThrowsError(try manager.createPractice(
            date: Date(),
            time: Date(),
            type: .competition,
            sections: [""],  // Empty competition name
            intensity: 0.5
        ))
    }
    
    func testPracticeValidation() {
        // Test various invalid scenarios
        let invalidCases: [(Practice, String)] = [
            (Practice(
                date: Date(),
                type: .competition,
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
            ), "Invalid intensity below 0"),
            
            (Practice(
                date: Date(),
                type: .practice,
                sections: [""],
                intensity: 1.1,
                isFromTemplate: false
            ), "Invalid intensity above 1")
        ]
        
        for (practice, description) in invalidCases {
            XCTAssertFalse(mockService.validate(practice), description)
        }
    }
} 