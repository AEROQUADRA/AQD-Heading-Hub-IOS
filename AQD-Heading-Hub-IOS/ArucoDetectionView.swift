import SwiftUI
import AVFoundation

// UIViewControllerRepresentable for Aruco Detection
struct ArucoDetectionView: UIViewControllerRepresentable {
    @Binding var detectedMarker: (id: Int, distance: Double)?
    @Binding var isMoving: Bool // Track when to move to the next view

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ArucoDetectionViewController {
        let viewController = ArucoDetectionViewController()
        viewController.onMarkerDetected = { markerId, markerDistance in
            self.detectedMarker = (id: markerId, distance: markerDistance)
            context.coordinator.handleMarkerDetected(markerId: markerId, markerDistance: markerDistance)
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: ArucoDetectionViewController, context: Context) {}

    class Coordinator: NSObject {
        var parent: ArucoDetectionView

        init(_ parent: ArucoDetectionView) {
            self.parent = parent
        }

        // Handle marker detection and transition to MoveView
        func handleMarkerDetected(markerId: Int, markerDistance: Double) {
            DispatchQueue.main.async {
                // When a marker is detected, transition to MoveView
                self.parent.isMoving = true
            }
        }
    }
}

// ArucoDetectionViewController for handling camera and marker detection
class ArucoDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession?
    var isDetecting = true

    // Closure to handle detected marker
    var onMarkerDetected: ((Int, Double) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    func setupCamera() {
        captureSession = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to access the camera.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession?.addInput(input)
        } catch {
            print("Error accessing the camera: \(error.localizedDescription)")
            return
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession?.addOutput(videoOutput)

        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)

        captureSession?.startRunning()
        print("Camera setup complete. Running marker detection.")
    }

    func stopCamera() {
        guard let session = captureSession, session.isRunning else { return }
        print("Stopping camera session...")
        session.stopRunning()
        captureSession = nil
        print("Camera stopped.")
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("isDetecting status: \(isDetecting)")

        // Avoid processing frames if marker is already detected
        guard isDetecting else {
            print("Detection has been halted, skipping frame.")
            return
        }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer.")
            return
        }

        let detectedMarkers = ArucoCV.detectMarkers(inFrame: pixelBuffer)

        // Properly cast elements of NSArray
        for marker in detectedMarkers {
            if let markerDict = marker as? [String: Any],
               let id = markerDict["id"] as? Int,
               let distance = markerDict["distance"] as? Double {
                print("Marker detected! ID: \(id), Distance: \(distance)")
                self.isDetecting = false // Safely stop further detection

                // Stop detecting as soon as marker is found
                DispatchQueue.main.sync {
                    print("isDetecting set to false. Stopping further detection.")
                    self.stopCamera() // Stop camera session
                    self.onMarkerDetected?(id, distance)
                }
                break
            } else {
                print("Failed to cast marker to expected dictionary format.")
            }
        }
    }
}
