import SwiftUI

struct MoveController: View {
    var markerID: Int?
    var distance: Float?

    var body: some View {
        VStack {
            Text("Marker Detected")
                .font(.largeTitle)
                .padding()

            if let markerID = markerID {
                Text("Marker ID: \(markerID)")
                    .font(.title)
                    .padding()
            }

            if let distance = distance {
                Text("Distance: \(String(format: "%.2f", distance)) meters")
                    .font(.title)
                    .padding()
            }

            Spacer()
        }
        .navigationBarTitle("Marker Details", displayMode: .inline)
    }
}
