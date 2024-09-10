import SwiftUI

struct ContentView: View {
    @State private var detectedIDs: [Int] = []
    @State private var closestMarkerID: Int?
    @State private var closestMarkerDistance: Float?
    @State private var markerDetected = false  // This will trigger navigation once marker is detected

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to AQD Heading Hub")
                    .font(.largeTitle)
                    .padding()

                // Button to go to the ArUco detection view
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

                // This ensures that once markerDetected is true, you move to MoveController
                NavigationLink(
                    destination: MoveController(markerID: closestMarkerID, distance: closestMarkerDistance),
                    isActive: $markerDetected
                ) {
                    EmptyView() // The navigation happens programmatically based on marker detection
                }
            }
        }
    }
}
