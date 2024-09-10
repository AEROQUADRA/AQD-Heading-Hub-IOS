import SwiftUI

struct CommandsView: View {
    private let commandService = CommandService()  // Command service to send commands to ESP8266
    
    @State private var leftSpeed = 100  // Default left motor speed
    @State private var rightSpeed = 100  // Default right motor speed
    @State private var commandResult: String = ""  // Result of the command sent

    var body: some View {
        VStack {
            Text("Control ESP8266")  // Title for the screen
                .font(.title)
                .padding()

            // Buttons to control the ESP8266
            HStack(spacing: 20) {
                Button(action: { sendCommand("FORWARD") }) {
                    Text("Forward")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: { sendCommand("BACKWARD") }) {
                    Text("Backward")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            HStack(spacing: 20) {
                Button(action: { sendCommand("LEFT") }) {
                    Text("Left")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: { sendCommand("RIGHT") }) {
                    Text("Right")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: { sendCommand("STOP") }) {
                    Text("Stop")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            // Display the result of the command
            Text("Command Result: \(commandResult)")
                .padding()
                .foregroundColor(.green)
        }
        .padding()
    }

    // Function to send commands to the ESP8266
    private func sendCommand(_ cmd: String) {
        commandService.sendCommand(cmd, leftSpeed: leftSpeed, rightSpeed: rightSpeed) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    commandResult = response  // Show the response in the UI
                case .failure(let error):
                    commandResult = "Error: \(error.localizedDescription)"  // Show error message
                }
            }
        }
    }
}
