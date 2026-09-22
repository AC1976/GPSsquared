// GPSsquared_terminal is a terminal script to test the GPSsquared library 
// Coded by Google Gemini, inspired by work for www.crassus.pro - the definite real property management app for solo operators
// Free use for all, no license applies.

import Foundation
import GPSsquared

print("=============================================")
print("  Real Estate Imperium Area Calculator Tool  ")
print("=============================================")
print("Type 'done' when you are finished entering coordinates.")
print("Type 'exit' to quit the program.")
print("---------------------------------------------")

var enteredCoordinates = [GPSCoordinate]()
let calculator = GPSAreaCalculator()

while true {
    let buildingNumber = enteredCoordinates.count + 1
    print("\nBuilding #\(buildingNumber) - Enter coordinates (Format: latitude, longitude):")
    print("> ", terminator: "")
    
    guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        continue
    }
    
    let lowercaseInput = input.lowercased()
    
    if lowercaseInput == "exit" {
        print("Goodbye!")
        break
    }
    
    if lowercaseInput == "done" {
        if enteredCoordinates.count < 3 {
            print("⚠️ You need at least 3 coordinates to calculate a shape area. You currently have \(enteredCoordinates.count).")
            continue
        }
        
        // Use our new library function to get BOTH the area and the outer boundary points
        let result = calculator.calculateImperiumOutline(from: enteredCoordinates)
        
        print("\n================ CALCULATING =================")
        print("Processed \(enteredCoordinates.count) total building locations.")
        print("Boundary shape requires \(result.outline.count) perimeter nodes.")
        print(String(format: "Tightest fitting footprint area: %.4f square kilometers", result.area))
        print("=============================================")
        
        // Ask if they want to export the perimeter coordinates
        print("\nWould you like to export the hull outline coordinates to a file? (yes/no)")
        print("> ", terminator: "")
        if let exportInput = readLine()?.lowercased(), exportInput.hasPrefix("y") {
            
            // Format the coordinates nicely as plain text
            var fileContent = "Latitude, Longitude (Convex Hull Perimeter Nodes)\n"
            for coord in result.outline {
                fileContent += "\(coord.latitude), \(coord.longitude)\n"
            }
            
            // Save it directly to the user's current working directory on Windows
            let fileName = "imperium_hull_outline.txt"
            let currentPath = FileManager.default.currentDirectoryPath
            let fileURL = URL(fileURLWithPath: currentPath).appendingPathComponent(fileName)
            
            do {
                try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
                print("💾 Success! Outline coordinates saved to: \(fileURL.path)")
            } catch {
                print("❌ Failed to save file: \(error.localizedDescription)")
            }
        }
        
        // Restart or exit prompt
        print("\nWould you like to start a new calculation? (yes/no)")
        print("> ", terminator: "")
        if let resetInput = readLine()?.lowercased(), resetInput.hasPrefix("y") {
            enteredCoordinates.removeAll()
            print("\n--- Resetting. Enter new points below ---")
            continue
        } else {
            print("Goodbye!")
            break
        }
    }
    
    let components = input.components(separatedBy: ",")
    guard components.count == 2,
          let lat = Double(components[0].trimmingCharacters(in: .whitespaces)),
          let lon = Double(components[1].trimmingCharacters(in: .whitespaces)) else {
        print("❌ Invalid format. Please enter numbers separated by a comma.")
        continue
    }
    
    guard lat >= -90.0 && lat <= 90.0 && lon >= -180.0 && lon <= 180.0 else {
        print("❌ Coordinates out of physical bounds.")
        continue
    }
    
    let newCoord = GPSCoordinate(latitude: lat, longitude: lon)
    enteredCoordinates.append(newCoord)
    print("✅ Added coordinate (\(lat), \(lon))")
}
