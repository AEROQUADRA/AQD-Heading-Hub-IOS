import SwiftUI

struct ContentView: View {
    @State private var detectedIDs: [Int] = []  // Declare detectedIDs as @State

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to AQD Heading Hub")
                    .font(.largeTitle)
                    .padding()

                NavigationLink(destination: DetectionViewController(detectedIDs: $detectedIDs)) {  // Pass the binding using $
                    Text("Start ArUco Detection")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}
