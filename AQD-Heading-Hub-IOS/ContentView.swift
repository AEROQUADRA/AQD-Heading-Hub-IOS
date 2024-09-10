import SwiftUI

struct ContentView: View {
    @State private var detectedMarker: (id: Int, distance: Double)? = nil
    @State private var isShowingMarkerDetails = false
    @StateObject private var networkService = NetworkService()  // Network Monitoring

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "camera.viewfinder")
                    .imageScale(.large)
                    .foregroundColor(.blue)
                Text("Detect ArUco Marker")

                // Navigation to ArucoDetectionView
                NavigationLink(destination: ArucoDetectionView(detectedMarker: $detectedMarker, isShowingMarkerDetails: $isShowingMarkerDetails)) {
                    Text("Start ArUco Detection")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Navigate to MarkerDetailView once a marker is detected
                if let marker = detectedMarker, isShowingMarkerDetails {
                    NavigationLink(
                        destination: MarkerDetailView(markerID: marker.id, distance: marker.distance),
                        isActive: $isShowingMarkerDetails
                    ) {
                        EmptyView()
                    }
                }

                // Display WiFi network information
                VStack {
                    Text("Connected SSID: \(networkService.connectedSSID)")
                    Text("Connected IP: \(networkService.connectedIP)")
                }
                .padding()
                .foregroundColor(.gray)

                // Button to navigate to CommandsView
                NavigationLink(destination: CommandsView()) {
                    Text("Commands")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Button to navigate to SettingsView
                NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}
