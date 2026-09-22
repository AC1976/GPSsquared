# 🌍 GPSsquared

A highly efficient, cross-platform Swift package designed to calculate the precise geometric boundaries of geographic locations. Built with the **Andrew's Monotone Chain (Convex Hull)** algorithm and the **Shoelace Formula**, it maps real-world coordinates onto a localized flat-plane grid to determine areas with absolute precision and **minimal extra mileage**.

Developed on Windows 11 with the modern Swift 6 toolchain, it features native, seamless integration with **Apple MapKit** out of the box when imported into iOS, macOS, or visionOS environments.

---

## ✨ Features

* **Tightest Fit Footprint:** Uses a Convex Hull algorithm to wrap your points like a rubber band, ignoring internal points to isolate only the outermost perimeter.
* **Accurate Spatial Units:** Translates decimal GPS strings into localized Cartesian grids to output results cleanly in square kilometers (km²).
* **Cross-Platform DNA:** Fully functional as a CLI interactive utility tool on Windows/Linux, yet automatically compiles platform-native types on Apple OS.
* **Zero Boilerplate MapKit integration:** Includes automatic conditional compilation (`#if canImport(CoreLocation)`) to bridge custom objects directly into `CLLocationCoordinate2D`.

---

## 🛠️ Installation (Swift Package Manager)

To add `GPSsquared` to your project, simply add it as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com", from: "1.0.0")
]
```

Or, in **Xcode**, simply navigate to `File ➔ Add Package Dependencies...` and paste your repository link.

---

## 💻 Usage

### 1. Cross-Platform Core Library
You can use the platform-agnostic `GPSCoordinate` struct on any OS (Windows, Linux, Apple) to compute footprints dynamically:

```swift
import GPSsquared

let properties = [
    GPSCoordinate(latitude: 40.7644, longitude: -73.9730),
    GPSCoordinate(latitude: 40.7681, longitude: -73.9819),
    GPSCoordinate(latitude: 40.8003, longitude: -73.9582),
    GPSCoordinate(latitude: 40.7965, longitude: -73.9671)
]

let calculator = GPSAreaCalculator()
let result = calculator.calculateImperiumOutline(from: properties)

print("Area: \(result.area) sq km")
print("Perimeter contains \(result.outline.count) nodes.")
```

### 2. Bring It Into Scope with SwiftUI & MapKit 📲
When compiled inside an Apple environment, `GPSCoordinate` exposes the native `.mapKitCoordinate` helper, allowing you to feed boundaries directly into a map overlay with standard rendering parameters:

```swift
import SwiftUI
import MapKit
import GPSsquared

struct ImperiumMapView: View {
    let myRealEstateCoordinates: [GPSCoordinate]
    let calculator = GPSAreaCalculator()
    
    var mapKitOutline: [CLLocationCoordinate2D] {
        let result = calculator.calculateImperiumOutline(from: myRealEstateCoordinates)
        return result.outline.map { $0.mapKitCoordinate }
    }
    
    var body: some View {
        Map {
            // MapKit traces the array sequentially and fills the interior tightly!
            MapPolygon(coordinates: mapKitOutline)
                .foregroundStyle(.purple.opacity(0.3))
                .stroke(.purple, lineWidth: 2)
        }
    }
}
```

---

## 🧪 Local Prototyping Terminal Tool

The package ships with an integrated standalone terminal tester (`GPSsquared_terminal`). Run this command inside your workspace on Windows or Mac to test your coordinates interactively or check validation bounds before writing frontend UI code:

```bash
swift run GPSsquared_terminal
```

```text
=============================================
  Real Estate Imperium Area Calculator Tool  
=============================================
Building #1 - Enter coordinates (Format: latitude, longitude):
> 40.7644, -73.9730
✅ Added coordinate (40.7644, -73.973)

...

Building #5 - Enter coordinates:
> done

================ CALCULATING =================
Processed 4 total building locations.
Boundary shape requires 4 perimeter nodes.
Tightest fitting footprint area: 👉 3.4150 square kilometers
=============================================
```

---

## ⚖️ License

This project is licensed under the MIT License - feel free to use it to map your own real estate empires!
