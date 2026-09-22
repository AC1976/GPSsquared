// GPSSquared calculates the minimum square kilometrage for any set of GPS coords (min 3)
// by drawing a convex hull shape around the points.
// Coded by Google Gemini, inspired by work for www.crassus.pro - the definite real property management app for solo operators
// Free use for all, no license applies.

import Foundation

// 1. Conditionally import Apple's native framework if available
#if canImport(CoreLocation)
import CoreLocation
#endif

/// Represents a GPS coordinate using decimal degrees.
/// Automatically bridges to Apple's native `CLLocationCoordinate2D` when compiled on Apple platforms.
public struct GPSCoordinate: Equatable {
    public var latitude: Double
    public var longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // 2. Add an elegant property helper specifically for MapKit developers
    #if canImport(CoreLocation)
    /// Converts this platform-agnostic coordinate into Apple's native MapKit coordinate type.
    public var mapKitCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    #endif
}

struct CartesianPoint: Comparable {
    let x: Double
    let y: Double
    
    static func < (lhs: CartesianPoint, rhs: CartesianPoint) -> Bool {
        if lhs.x != rhs.x { return lhs.x < rhs.x }
        return lhs.y < rhs.y
    }
}

public struct GPSAreaCalculator {
    public init() {}
    
    public func calculateImperiumOutline(from coordinates: [GPSCoordinate]) -> (area: Double, outline: [GPSCoordinate]) {
        guard coordinates.count >= 3 else { return (0.0, []) }
        
        let points = projectToLocalCartesian(coordinates)
        let hullPoints = computeConvexHull(points)
        guard !hullPoints.isEmpty else { return (0.0, []) }
        
        let area = calculatePolygonArea(hullPoints)
        
        var orderedGPSOutline = [GPSCoordinate]()
        let originalCartesian = projectToLocalCartesian(coordinates)
        
        for hullPoint in hullPoints {
            if let originalIndex = originalCartesian.firstIndex(where: { 
                abs($0.x - hullPoint.x) < 0.00001 && abs($0.y - hullPoint.y) < 0.00001 
            }) {
                orderedGPSOutline.append(coordinates[originalIndex])
            }
        }
        
        return (area, orderedGPSOutline)
    }
    
    private func projectToLocalCartesian(_ coordinates: [GPSCoordinate]) -> [CartesianPoint] {
        guard let origin = coordinates.first else { return [] }
        let latOriginRad = origin.latitude * .pi / 180.0
        let kmPerDegreeLat = 111.32
        let kmPerDegreeLon = 111.32 * cos(latOriginRad)
        
        return coordinates.map { coord in
            CartesianPoint(
                x: (coord.longitude - origin.longitude) * kmPerDegreeLon,
                y: (coord.latitude - origin.latitude) * kmPerDegreeLat
            )
        }
    }
    
    private func computeConvexHull(_ points: [CartesianPoint]) -> [CartesianPoint] {
        let sortedPoints = points.sorted()
        var uniquePoints = [CartesianPoint]()
        for point in sortedPoints {
            if uniquePoints.last != point { uniquePoints.append(point) }
        }
        guard uniquePoints.count >= 3 else { return [] }
        
        func crossProduct(_ o: CartesianPoint, _ a: CartesianPoint, _ b: CartesianPoint) -> Double {
            return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
        }
        
        var lower = [CartesianPoint]()
        for p in uniquePoints {
            while lower.count >= 2 && crossProduct(lower[lower.count - 2], lower[lower.count - 1], p) <= 0 { lower.removeLast() }
            lower.append(p)
        }
        
        var upper = [CartesianPoint]()
        for p in uniquePoints.reversed() {
            while upper.count >= 2 && crossProduct(upper[upper.count - 2], upper[upper.count - 1], p) <= 0 { upper.removeLast() }
            upper.append(p)
        }
        
        lower.removeLast()
        upper.removeLast()
        return lower + upper
    }
    
    private func calculatePolygonArea(_ hull: [CartesianPoint]) -> Double {
        guard hull.count >= 3 else { return 0.0 }
        var area = 0.0
        let j = hull.count - 1
        for i in 0..<hull.count {
            let current = hull[i]
            let previous = hull[(i + j) % hull.count]
            area += (previous.x + current.x) * (previous.y - current.y)
        }
        return abs(area) / 2.0
    }
}
