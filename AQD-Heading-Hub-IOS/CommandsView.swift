import SwiftUI

struct CommandsView: View {
    private let commandService = CommandService()  // Command service to send commands to ESP8266
    
    @State private var leftSpeed = 100  // Default left motor speed
    @State private var rightSpeed = 100  // Default right motor speed
    @State private var commandResult: String = ""  // Result of the command sent
    
    @Environment(\.presentationMode) var presentationMode  // To dismiss the view
    @StateObject private var networkService = NetworkService()  // For Wi-Fi info
    @State private var showAlert = false  // Alert flag
    @State private var alertMessage = ""  // Alert message

    var body: some View {
        VStack {
            if networkService.connectedIP == "192.168.4.3" {
                Text("Control ESP8266")
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
            } else {
                // Show message if not connected to correct Wi-Fi
                VStack {
                    Text("Please connect to 'AQD HUB' Wi-Fi and try again.")
                        .font(.headline)
                        .padding()
                    Button(action: {
                        // Dismiss view to go back
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Go Back")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            // Only show the alert if the IP is incorrect
            if networkService.connectedIP != "192.168.4.3" {
                showAlert = true
                alertMessage = "You are not connected to 'AQD HUB' Wi-Fi. Please connect and try again."
            } else {
                showAlert = false  // No need to show alert if connected to correct IP
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Connection Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
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
