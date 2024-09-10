import SwiftUI
import ARKit
import SceneKit

// Define ArucoProperty struct to hold Aruco marker properties
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
        var mutexlock = false

        init(_ parent: DetectionViewController) {
            self.parent = parent
        }

        // Conform to ARSCNViewDelegate
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            // Handle any scene rendering updates if needed
        }

        // Conform to ARSessionDelegate
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            if mutexlock { return }

            mutexlock = true
            let pixelBuffer = frame.capturedImage

            // Safely cast the result of estimatePose to [SKWorldTransform]
            if let transMatrixArray = ArucoCV.estimatePose(pixelBuffer, withIntrinsics: frame.camera.intrinsics, andMarkerSize: ArucoProperty.ArucoMarkerSize) as? [SKWorldTransform] {

                if !transMatrixArray.isEmpty {
                    DispatchQueue.main.async {
                        // Store detected marker IDs
                        self.parent.detectedIDs = transMatrixArray.map { Int($0.arucoId) }

                        // Calculate distances and find the closest marker
                        var closestMarkerID: Int?
                        var closestDistance: Float = Float.greatestFiniteMagnitude

                        for transform in transMatrixArray {
                            // Convert SCNMatrix4 to matrix_float4x4 using simd_float4x4
                            let matrix = simd_float4x4(transform.transform)
                            let distance = self.calculateDistance(from: matrix)
                            if distance < closestDistance {
                                closestDistance = distance
                                closestMarkerID = Int(transform.arucoId)
                            }
                        }

                        // Update the closest marker information
                        if let closestMarkerID = closestMarkerID {
                            self.parent.closestMarkerID = closestMarkerID
                            self.parent.closestMarkerDistance = closestDistance
                            self.parent.markerDetected = true
                        }
                    }
                }
            } else {
                print("Failed to detect markers.")
            }

            mutexlock = false
        }

        // Function to calculate distance from transformation matrix
        func calculateDistance(from matrix: matrix_float4x4) -> Float {
            let translation = matrix.columns.3
            return sqrt(translation.x * translation.x + translation.y * translation.y + translation.z * translation.z)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator

        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)

        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}
}

struct ArucoContentView: View {
    @State private var detectedIDs: [Int] = []
    @State private var closestMarkerID: Int?
    @State private var closestMarkerDistance: Float?
    @State private var markerDetected = false

    var body: some View {
        VStack {
            if markerDetected {
                // Navigate to MoveController when a marker is detected
                NavigationLink(
                    destination: MoveController(markerID: closestMarkerID, distance: closestMarkerDistance),
                    isActive: $markerDetected
                ) {
                    EmptyView() // The navigation link is triggered when a marker is detected
                }
            }

            DetectionViewController(
                detectedIDs: $detectedIDs,
                closestMarkerID: $closestMarkerID,
                closestMarkerDistance: $closestMarkerDistance,
                markerDetected: $markerDetected
            )
            .edgesIgnoringSafeArea(.all)
            .frame(height: 500)

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
