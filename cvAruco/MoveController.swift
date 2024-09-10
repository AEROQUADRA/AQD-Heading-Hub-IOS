import SwiftUI

struct MoveController: View {
    var markerID: Int?
    var distance: Float?

    var body: some View {
        VStack {
            if let markerID = markerID, let distance = distance {
                Text("Marker ID: \(markerID)")
                    .font(.largeTitle)
                    .padding()

                Text(String(format: "Distance: %.2f meters", distance))
                    .font(.title)
                    .padding()
            } else {
                Text("No marker detected.")
                    .font(.title)
                    .padding()
            }

            Spacer()
        }
        .navigationTitle("Marker Details")
    }
}
