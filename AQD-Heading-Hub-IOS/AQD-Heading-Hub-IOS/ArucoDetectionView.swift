import SwiftUI
import AVFoundation

struct ArucoDetectionView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ArucoDetectionViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update as needed
    }
}

class ArucoDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

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

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)

        captureSession?.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Detect ArUco markers
        let detectedMarkers = ArucoCV.detectMarkers(inFrame: pixelBuffer)
        
        DispatchQueue.main.async {
            if detectedMarkers.count > 0 {
                print("Detected Marker IDs: \(detectedMarkers)")
            }
        }
    }
}
