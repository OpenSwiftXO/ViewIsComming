import SwiftUI
import ViewIsComming

struct PowerKaleidoView: View {
    @State private var showView = true
    @State private var scale: Double = 2.0
    @State private var z: Double = 1.5
    @State private var speed: Double = 5.0
    
    var body: some View {
        ScrollView {
            ZStack {
                if showView {
                    Image(.haNoi)
                        .resizable()
                        .transition(
                            .powerKaleido(
                                scale: scale,
                                z: z,
                                speed: speed
                            )
                        )
                }
            }
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading) {
                    Text("Scale: \(scale, specifier: "%.2f")")
                        .font(.caption)
                    Slider(value: $scale, in: 0.5...5.0)
                }
                VStack(alignment: .leading) {
                    Text("Z: \(z, specifier: "%.2f")")
                        .font(.caption)
                    Slider(value: $z, in: 0.0...5.0)
                }
                VStack(alignment: .leading) {
                    Text("Speed: \(speed, specifier: "%.1f")")
                        .font(.caption)
                    Slider(value: $speed, in: 0.0...10.0)
                }
                
                HStack(spacing: 10) {
                    Button("Default") {
                        scale = 2.0
                        z = 1.5
                        speed = 5.0
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Mellow") {
                        scale = 3.0
                        z = 0.8
                        speed = 2.0
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Wild") {
                        scale = 1.2
                        z = 3.0
                        speed = 8.0
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 1.5)) {
                    showView.toggle()
                }
            }) {
                Text("Toggle Transition")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("PowerKaleido")
    }
}

