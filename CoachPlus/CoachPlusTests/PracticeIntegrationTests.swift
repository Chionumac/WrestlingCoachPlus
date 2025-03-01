import XCTest
@testable import CoachPlus

final class PracticeIntegrationTests: XCTestCase {
    var practiceService: MockPracticeService!
    var templateService: MockTemplateService!
    var practiceManager: PracticeManager!
    var viewModel: PracticeViewModel!
    
    override func setUp() {
        super.setUp()
        practiceService = MockPracticeService()
        templateService = MockTemplateService()
        practiceManager = PracticeManager(service: practiceService)
        viewModel = PracticeViewModel()
    }
    
    override func tearDown() {
        practiceService.reset()
        templateService.reset()
        practiceService = nil
        templateService = nil
        practiceManager = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Integration Tests
    
    func testCreatePracticeFromTemplate() throws {
        // Given
        let template = PracticeTemplate(
            name: "Test Template",
            sections: ["Warm up", "Main set"],
            intensity: 0.7,
            liveTimeMinutes: 30,
            includesLift: true,
            practiceTime: Date()
        )
        try templateService.save(template)
        
        // When
        viewModel.createPracticeFromTemplate(template, date: Date())
        
        // Then
        XCTAssertEqual(viewModel.state, .success)
        XCTAssertFalse(viewModel.practices.isEmpty)
        let practice = viewModel.practices.first
        XCTAssertEqual(practice?.sections, template.sections)
        XCTAssertEqual(practice?.intensity, template.intensity)
        XCTAssertEqual(practice?.includesLift, template.includesLift)
    }
    
    func testRecurringPracticeCreation() throws {
        // Given
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
        
        // When
        viewModel.createRecurringPractices(
            startDate: startDate,
            endDate: endDate,
            pattern: .daily,
            time: Date(),
            type: .practice,
            sections: ["Daily Practice"],
            intensity: 0.6,
            includesLift: false,
            liveTimeMinutes: 0
        )
        
        // Then
        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(viewModel.practices.count, 8) // Including start and end dates
    }
    
    func testCompetitionCreation() {
        // Given
        let date = Date()
        let sections = [
            "Competition: Test Meet",
            "Results: https://results.com",
            "Video: https://video.com",
            "Performance: Great performance"
        ]
        
        // When
        viewModel.createPractice(
            date: date,
            time: date,
            type: .competition,
            sections: sections,
            intensity: 0.9
        )
        
        // Then
        XCTAssertEqual(viewModel.state, .success)
        let competition = viewModel.practiceForDate(date)
        XCTAssertEqual(competition?.type, .competition)
        XCTAssertEqual(competition?.sections, sections)
    }
    
    func testStateManagement() {
        // Test loading state
        viewModel.createPractice(
            date: Date(),
            time: Date(),
            type: .practice,
            sections: ["Test Practice"],
            intensity: 0.5
        )
        
        // Then - Should go through loading -> success
        XCTAssertEqual(viewModel.state, .success)
        
        // Test error state
        practiceService.shouldFail = true
        viewModel.createPractice(
            date: Date(),
            time: Date(),
            type: .practice,
            sections: [],  // Invalid sections
            intensity: 0.5
        )
        
        if case .error = viewModel.state {
            XCTAssertTrue(true) // Error state achieved
        } else {
            XCTFail("Expected error state")
        }
    }
} 