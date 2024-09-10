import SwiftUI
import ARKit
import SceneKit

struct ArucoProperty {
    static let ArucoMarkerSize: Float64 = 0.05  // Marker size of 5 cm
}

struct DetectionViewController: UIViewRepresentable {
    @Binding var detectedIDs: [Int]
    @Binding var closestMarkerID: Int?
    @Binding var closestMarkerDistance: Float?
    @Binding var markerDetected: Bool

    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var parent: DetectionViewController
        var sceneView: ARSCNView?

        init(_ parent: DetectionViewController) {
            self.parent = parent
        }

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Check if the marker has already been detected to stop further processing.
            guard !parent.markerDetected else {
                print("Marker already detected, pausing session.")
                pauseSession() // Pause the session to stop further updates.
                return
            }

            let pixelBuffer = frame.capturedImage

            // Detect Aruco marker
            if let transMatrixArray = ArucoCV.estimatePose(pixelBuffer, withIntrinsics: frame.camera.intrinsics, andMarkerSize: ArucoProperty.ArucoMarkerSize) as? [SKWorldTransform] {
                if !transMatrixArray.isEmpty {
                    DispatchQueue.main.async {
                        var closestMarkerID: Int?
                        var closestDistance: Float = Float.greatestFiniteMagnitude

                        for transform in transMatrixArray {
                            let matrix = simd_float4x4(transform.transform)
                            let distance = self.calculateDistance(from: matrix)
                            if distance < closestDistance {
                                closestDistance = distance
                                closestMarkerID = Int(transform.arucoId)
                            }
                        }

                        // Update detected marker details and stop further detection
                        if let closestMarkerID = closestMarkerID {
                            self.parent.detectedIDs = transMatrixArray.map { Int($0.arucoId) }
                            self.parent.closestMarkerID = closestMarkerID
                            self.parent.closestMarkerDistance = closestDistance
                            self.parent.markerDetected = true

                            print("Marker Detected: ID = \(closestMarkerID), Distance = \(closestDistance)")

                            // Immediately pause the AR session and prevent further detection
                            self.pauseSession()

                            // Move to new screen once marker is detected
                            self.moveToMoveController()
                        }
                    }
                }
            }
        }

        func calculateDistance(from matrix: simd_float4x4) -> Float {
            let translation = matrix.columns.3
            return sqrt(translation.x * translation.x + translation.y * translation.y + translation.z * translation.z)
        }

        // Ensure the session is paused properly
        func pauseSession() {
            guard let sceneView = sceneView else { return }
            print("Pausing AR session.")
            sceneView.session.pause()  // Stop the AR session to halt further updates.
        }

        func moveToMoveController() {
            print("Navigating to new controller...")
            // Navigation logic here, ensure session is paused
            pauseSession()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        context.coordinator.sceneView = sceneView
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator

        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)

        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}
}
