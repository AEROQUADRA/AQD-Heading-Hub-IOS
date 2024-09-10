import SwiftUI

struct ArucoContentView: View {
    @State private var detectedIDs: [Int] = []
    @State private var closestMarkerID: Int?
    @State private var closestMarkerDistance: Float?
    @State private var markerDetected = false  // This will trigger navigation

    var body: some View {
        NavigationView {
            VStack {
                // NavigationLink that gets triggered programmatically once markerDetected is true
                NavigationLink(
                    destination: MoveController(markerID: closestMarkerID, distance: closestMarkerDistance),
                    isActive: $markerDetected  // This binding triggers the navigation
                ) {
                    EmptyView()  // EmptyView because this is triggered programmatically
                }

                // AR view that detects the markers
                DetectionViewController(
                    detectedIDs: $detectedIDs,
                    closestMarkerID: $closestMarkerID,
                    closestMarkerDistance: $closestMarkerDistance,
                    markerDetected: $markerDetected
                )
                .edgesIgnoringSafeArea(.all)
                .frame(height: 500)

                // Display detected marker IDs
                if !detectedIDs.isEmpty {
                    Text("Detected ArUco Marker IDs:")
                    ForEach(detectedIDs, id: \.self) { id in
                        Text("Marker ID: \(id)")
                            .font(.headline)
                    }
                } else {
                    Text("No ArUco markers detected.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
