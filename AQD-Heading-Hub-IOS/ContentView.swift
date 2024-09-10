import SwiftUI

struct ContentView: View {
    @State private var detectedMarker: (id: Int, distance: Double)? = nil

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "camera.viewfinder")
                    .imageScale(.large)
                    .foregroundColor(.blue)
                Text("Detect ArUco Marker")

                // Navigate to ArucoDetectionView
                NavigationLink(destination: ArucoDetectionView(detectedMarker: $detectedMarker)) {
                    Text("Start ArUco Detection")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
