import SwiftUI

struct ContentView: View {
    @State private var detectedIDs: [Int] = []  // State variable for detected IDs
    @State private var closestMarkerID: Int?
    @State private var closestMarkerDistance: Float?
    @State private var markerDetected = false   // Tracks if a marker has been detected

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to AQD Heading Hub")
                    .font(.largeTitle)
                    .padding()

                // Button to start detection
                NavigationLink(
                    destination: DetectionViewController(
                        detectedIDs: $detectedIDs,
                        closestMarkerID: $closestMarkerID,
                        closestMarkerDistance: $closestMarkerDistance,
                        markerDetected: $markerDetected
                    )
                ) {
                    Text("Start ArUco Detection")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}
