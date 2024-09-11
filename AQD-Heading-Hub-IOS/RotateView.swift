import SwiftUI

struct RotateView: View {
    @Binding var isRotating: Bool
    @Binding var isDetecting: Bool
    private let commandService = CommandService()  // Use a simple instance instead of @StateObject

    var body: some View {
        VStack {
            Text("Rotating to Correct Heading")

            Button("Rotate to Marker") {
                rotateToMarker()
            }
        }
        .onAppear {
            rotateToMarker()
        }
    }

    private func rotateToMarker() {
        commandService.sendCommand("LEFT", leftSpeed: 50, rightSpeed: 50) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.commandService.sendCommand("STOP", leftSpeed: 0, rightSpeed: 0) { _ in
                    // Reset the rotation state after rotating
                    self.isRotating = false
                    self.isDetecting = true  // Transition back to detection
                }
            }
        }
    }
}
