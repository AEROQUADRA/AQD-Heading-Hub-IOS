import SwiftUI

struct ContentView: View {
    @State private var detectedMarker: (id: Int, distance: Double)? = nil
    @State private var isMoving = false  // Added for transition to MoveView
    @State private var isRotating = false  // Added for transition to RotateView
    @StateObject private var networkService = NetworkService()  // Network Monitoring
    @State private var isCalibrated: Bool = UserDefaults.standard.bool(forKey: "isCalibrated")  // Camera calibration status

    var body: some View {
        NavigationView {
            VStack {
                if isMoving {
                    // Show MoveView after marker detection
                    MoveView(detectedMarker: $detectedMarker, isRotating: $isRotating)
                        .onChange(of: isRotating) { newValue in
                            if newValue {
                                isMoving = false  // Stop moving state once rotation starts
                            }
                        }
                } else if isRotating {
                    // Show RotateView after moving
                    RotateView(isRotating: $isRotating, isDetecting: $isMoving)
                } else {
                    Image(systemName: "camera.viewfinder")
                        .imageScale(.large)
                        .foregroundColor(.blue)
                    Text("Detect ArUco Marker")

                    // Navigation to ArucoDetectionView
                    NavigationLink(destination: ArucoDetectionView(detectedMarker: $detectedMarker, isMoving: $isMoving)) {
                        Text("Start ArUco Detection")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Display WiFi network information
                    VStack {
                        Text("Connected SSID: \(networkService.connectedSSID)")
                        Text("Connected IP: \(networkService.connectedIP)")
                    }
                    .padding()
                    .foregroundColor(.gray)

                    // Camera Calibration Status
                    Text(isCalibrated ? "Camera Calibrated" : "Camera Not Calibrated")
                        .foregroundColor(isCalibrated ? .green : .red)

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

                    // Button to navigate to Camera Calibration View
                    NavigationLink(destination: CameraCalibrationView(isCalibrated: $isCalibrated)) {
                        Text("Calibrate Camera")
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
}
