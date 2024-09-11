import SwiftUI
import AVFoundation

struct CameraCalibrationView: View {
    @Binding var isCalibrated: Bool
    @State private var capturedImages: [UIImage] = []
    @State private var isCalibrating = false
    @State private var progress = 0.0
    @State private var calibrationCompleted = false
    @State private var showCompletionAlert = false
    @State private var showingCamera = false

    var body: some View {
        VStack {
            if calibrationCompleted {
                Text("Calibration Completed!")
                    .font(.title)
                    .foregroundColor(.green)
            } else {
                Text("Capture Images for Calibration")
                    .font(.headline)
                ProgressView(value: progress, total: 50)
                    .padding()

                Button(action: {
                    startCalibration()
                }) {
                    Text(isCalibrating ? "Capturing..." : "Start Calibration")
                        .padding()
                        .background(isCalibrating ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: saveCalibrationData) {
                    Text("Save Calibration")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(!calibrationCompleted)
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingCamera) {
            CameraView(onCapture: handleCapturedImage)  // Custom camera view for capturing images
        }
        .alert(isPresented: $showCompletionAlert) {
            Alert(
                title: Text("Calibration Complete"),
                message: Text("The camera calibration data has been saved."),
                dismissButton: .default(Text("OK")) {
                    isCalibrated = true  // Update the calibration status
                }
            )
        }
    }

    func startCalibration() {
        isCalibrating = true
        showingCamera = true  // Show camera interface to capture images
    }

    func handleCapturedImage(image: UIImage) {
        capturedImages.append(image)
        progress = Double(capturedImages.count)

        if capturedImages.count >= 50 {
            calibrateCamera(capturedImages)
            showingCamera = false  // Stop showing camera once 50 images are captured
        }
    }

    func calibrateCamera(_ images: [UIImage]) {
        // Call to the CameraCalibration.mm to calibrate
        let imageSize = CGSize(width: 1920, height: 1080)  // Replace with actual image size
        let success = CameraCalibration.calibrateCamera(with: images, imageSize: imageSize)

        if success {
            calibrationCompleted = true
            showCompletionAlert = true
        } else {
            // Handle calibration failure (e.g., not enough corners detected)
            isCalibrating = false
        }
    }

    func saveCalibrationData() {
        // Save calibration data and update the status in ContentView
        UserDefaults.standard.set(true, forKey: "isCalibrated")
        isCalibrated = true
        showCompletionAlert = true
    }
}
