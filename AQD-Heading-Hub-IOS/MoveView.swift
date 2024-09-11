import SwiftUI

struct MoveView: View {
    @Binding var detectedMarker: (id: Int, distance: Double)?
    @Binding var isRotating: Bool  // To navigate to RotateView

    @State private var moveDuration: Int = 0  // Move duration calculated based on distance
    @State private var countdownText: String = "Starting..."
    @State private var statusText: String = "Preparing to move"
    @State private var distanceText: String = ""  // To display distance info
    @State private var detailsText: String = ""  // To display other details
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let commandService = CommandService()  // Service to send the commands

    var body: some View {
        VStack {
            Text("Moving to Marker")
                .font(.title)
                .padding()

            Text(countdownText)
                .padding()

            Text(statusText)
                .padding()

            Text(distanceText)
                .padding()

            Text(detailsText)
                .padding()

            if showAlert {
                Text(alertMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            logMessage("MoveView appeared")
            if let marker = detectedMarker {
                let moveDurationMs = calculateMoveDuration(distanceInMeters: marker.distance)
                self.moveDuration = moveDurationMs
                logMessage("Calculated move duration: \(moveDurationMs) ms")
                distanceText = String(format: "Distance to Marker: %.2f cm", marker.distance * 100)  // Show distance in cm
                startMove(duration: moveDurationMs)
            } else {
                logMessage("No marker detected")
                statusText = "No marker detected"
            }
        }
    }

    // Calculate move duration based on distance
    private func calculateMoveDuration(distanceInMeters: Double) -> Int {
        let distanceInMm = distanceInMeters * 1000  // Convert meters to millimeters
        let wheelDiameter = 43.0  // mm
        let wheelCircumference = Double.pi * wheelDiameter
        let wheelRevolutions = distanceInMm / wheelCircumference

        let wheelRPM = UserDefaults.standard.integer(forKey: "wheelRPM")
        let wheelRevolutionTime = 60.0 / Double(wheelRPM)  // Time for one revolution in seconds

        logMessage("Distance in mm: \(distanceInMm)")
        logMessage("Wheel Circumference: \(wheelCircumference)")
        logMessage("Wheel Revolutions: \(wheelRevolutions)")
        logMessage("Wheel Revolution Time: \(wheelRevolutionTime) seconds")
        logMessage("Wheel RPM: \(wheelRPM)")

        // Display the detailed info for debugging
        detailsText = String(format: "RPM: %d\nDiameter: %.2f mm\nCircumference: %.2f mm\nRevolutions: %.2f\nTime per revolution: %.2f s",
                             wheelRPM, wheelDiameter, wheelCircumference, wheelRevolutions, wheelRevolutionTime)

        // Return total move duration in milliseconds
        return Int(wheelRevolutions * wheelRevolutionTime * 1000)  // Convert to milliseconds
    }

    // Start moving
    private func startMove(duration: Int) {
        logMessage("Starting move for \(duration) ms")

        // Send move command asynchronously
        sendMoveCommand()

        var remainingTime = duration

        // Update the countdown every 100ms
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            remainingTime -= 100

            if remainingTime > 0 {
                self.countdownText = "Moving: \(Double(remainingTime) / 1000.0) seconds remaining"
            } else {
                timer.invalidate()  // Stop the timer once time is up
                self.countdownText = "Movement completed"
                sendStopCommand()
                transitionToRotateView()
            }
        }
    }

    // Send the move command
    private func sendMoveCommand() {
        let leftPower = UserDefaults.standard.integer(forKey: "moveLeftPower")
        let rightPower = UserDefaults.standard.integer(forKey: "moveRightPower")

        commandService.sendCommand("FORWARD", leftSpeed: leftPower, rightSpeed: rightPower) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.statusText = "Move command successful: \(response)"
                    logMessage("Move command successful: \(response)")
                case .failure(let error):
                    self.statusText = "Failed to send move command"
                    self.alertMessage = "Move command failed: \(error.localizedDescription)"
                    self.showAlert = true
                    logMessage("Failed to send move command: \(error.localizedDescription)")
                }
            }
        }
    }

    // Send the stop command after moving
    private func sendStopCommand() {
        commandService.sendCommand("STOP", leftSpeed: 0, rightSpeed: 0) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.statusText = "Stop command successful: \(response)"
                    logMessage("Stop command successful: \(response)")
                case .failure(let error):
                    self.alertMessage = "Failed to send stop command: \(error.localizedDescription)"
                    self.showAlert = true
                    logMessage("Failed to send stop command: \(error.localizedDescription)")
                }
            }
        }
    }

    // Transition to the RotateView after movement is done
    private func transitionToRotateView() {
        logMessage("Move completed, navigating to RotateView")
        isRotating = true
    }

    // Helper function to log messages
    private func logMessage(_ message: String) {
        print("LOG: \(message)")
    }
}
