import XCTest
import Foundation
@testable import GPSsquared

final class GPSsquaredTests: XCTestCase {
    
    let calculator = GPSAreaCalculator()
    
    func testInsufficientCoordinatesReturnsZeroArea() {
        let singlePoint = [GPSCoordinate(latitude: 40.7644, longitude: -73.9730)]
        let result = calculator.calculateImperiumOutline(from: singlePoint)
        
        XCTAssertEqual(result.area, 0.0, "An area cannot be calculated from a single coordinate.")
        XCTAssertTrue(result.outline.isEmpty, "Outline should be empty for insufficient data.")
    }
    
    func testCentralParkAreaCalculation() {
        let centralParkCoordinates = [
            GPSCoordinate(latitude: 40.7644, longitude: -73.9730), // SE Corner
            GPSCoordinate(latitude: 40.7681, longitude: -73.9819), // SW Corner
            GPSCoordinate(latitude: 40.8003, longitude: -73.9582), // NE Corner
            GPSCoordinate(latitude: 40.7965, longitude: -73.9671)  // NW Corner
        ]
        
        let result = calculator.calculateImperiumOutline(from: centralParkCoordinates)
        
        XCTAssertEqual(result.outline.count, 4, "The convex hull should capture all 4 perimeter points.")
        XCTAssertEqual(result.area, 2.6786, accuracy: 0.001, "The calculated area diverges too heavily from the baseline math.")
    }

    // 🛠️ Updated for Swift 6 Concurrency Compliance on Windows
    @MainActor static let allTests = [
        ("testInsufficientCoordinatesReturnsZeroArea", testInsufficientCoordinatesReturnsZeroArea),
        ("testCentralParkAreaCalculation", testCentralParkAreaCalculation),
    ]

}
import XCTest
