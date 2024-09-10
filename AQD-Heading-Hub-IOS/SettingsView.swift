import SwiftUI

struct SettingsView: View {
    // Fields for settings with default values from Android code
    @State private var wheelRPM: String = "125"  // Default value from Android code
    @State private var scalingFactor: String = "0.62"  // Default scaling factor
    @State private var rotateLeftPower: String = "75"  // Default rotate left power
    @State private var rotateRightPower: String = "75"  // Default rotate right power
    @State private var moveLeftPower: String = "75"  // Default move left power
    @State private var moveRightPower: String = "75"  // Default move right power
    
    let prefs = UserDefaults.standard  // Access to local storage
    @Environment(\.presentationMode) var presentationMode  // To dismiss view and go back

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .padding()

            // Wheel RPM field
            VStack(alignment: .leading) {
                Text("Wheel RPM")
                TextField("Enter Wheel RPM", text: $wheelRPM)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Scaling Factor field
            VStack(alignment: .leading) {
                Text("Scaling Factor")
                TextField("Enter Scaling Factor", text: $scalingFactor)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            // Rotation Power fields
            VStack(alignment: .leading) {
                Text("Rotate Left Power")
                TextField("Enter Rotate Left Power", text: $rotateLeftPower)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("Rotate Right Power")
                TextField("Enter Rotate Right Power", text: $rotateRightPower)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            // Movement Power fields
            VStack(alignment: .leading) {
                Text("Move Left Power")
                TextField("Enter Move Left Power", text: $moveLeftPower)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("Move Right Power")
                TextField("Enter Move Right Power", text: $moveRightPower)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Save button to store the settings
            Button(action: saveSettings) {
                Text("Save Settings")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: loadSettings)  // Load the saved settings when view appears
    }

    // Function to save settings to local storage (UserDefaults)
    private func saveSettings() {
        if let rpm = Int(wheelRPM), let scaling = Float(scalingFactor),
           let rotateLeft = Int(rotateLeftPower), let rotateRight = Int(rotateRightPower),
           let moveLeft = Int(moveLeftPower), let moveRight = Int(moveRightPower) {
           
            // Save to UserDefaults
            prefs.set(rpm, forKey: "wheelRPM")
            prefs.set(scaling, forKey: "scalingFactor")
            prefs.set(rotateLeft, forKey: "rotateLeftPower")
            prefs.set(rotateRight, forKey: "rotateRightPower")
            prefs.set(moveLeft, forKey: "moveLeftPower")
            prefs.set(moveRight, forKey: "moveRightPower")
            
            // Show a toast-like notification
            showNotification("Settings saved successfully.")
            
            // Navigate back to the main view
            presentationMode.wrappedValue.dismiss()
        } else {
            showNotification("Invalid input.")
        }
    }

    // Function to load settings from local storage
    private func loadSettings() {
        wheelRPM = String(prefs.integer(forKey: "wheelRPM") != 0 ? prefs.integer(forKey: "wheelRPM") : 125)
        scalingFactor = String(prefs.float(forKey: "scalingFactor") != 0.0 ? prefs.float(forKey: "scalingFactor") : 0.62)
        rotateLeftPower = String(prefs.integer(forKey: "rotateLeftPower") != 0 ? prefs.integer(forKey: "rotateLeftPower") : 75)
        rotateRightPower = String(prefs.integer(forKey: "rotateRightPower") != 0 ? prefs.integer(forKey: "rotateRightPower") : 75)
        moveLeftPower = String(prefs.integer(forKey: "moveLeftPower") != 0 ? prefs.integer(forKey: "moveLeftPower") : 75)
        moveRightPower = String(prefs.integer(forKey: "moveRightPower") != 0 ? prefs.integer(forKey: "moveRightPower") : 75)
    }


    // Helper function to show a notification (toast-like)
    private func showNotification(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
        
        // Dismiss alert after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
}
