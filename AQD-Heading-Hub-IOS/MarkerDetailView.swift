import SwiftUI

struct MarkerDetailView: View {
    var markerID: Int
    var distance: Double
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Marker Details")
                .font(.title)
                .bold()
            
            Text("Marker ID: \(markerID)")
                .font(.headline)
            
            Text(String(format: "Distance: %.2f meters", distance))
                .font(.subheadline)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Marker Info")
    }
}
