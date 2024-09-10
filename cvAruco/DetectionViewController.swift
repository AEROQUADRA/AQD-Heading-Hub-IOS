import SwiftUI
import ARKit
import SceneKit

// Define ArucoProperty struct to hold Aruco marker properties
struct ArucoProperty {
    static let ArucoMarkerSize: Float64 = 0.05  // Marker size of 5 cm
}

struct DetectionViewController: UIViewRepresentable {
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
                        self.parent.detectedIDs = transMatrixArray.map { Int($0.arucoId) }
                    }
                }
            } else {
                print("Failed to detect markers.")
            }

            mutexlock = false
        }
    }

    @Binding var detectedIDs: [Int]

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

    var body: some View {
        VStack {
            DetectionViewController(detectedIDs: $detectedIDs)
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
