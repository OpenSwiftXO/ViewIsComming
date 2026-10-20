import SwiftUI
import ViewIsComming

struct PixelizeView: View {
    @State private var showView = true
    @State private var squaresMin: Double = 20.0
    @State private var steps: Double = 20.0
    @State private var smoothTransition: Bool = false
    
    var body: some View {
        ScrollView {
            ZStack {
                if showView {
                    Image(.haNoi)
                        .resizable()
                        .transition(
                            .pixelize(
                                squaresMin: squaresMin,
                                steps: smoothTransition ? -1.0 : steps
                            )
                        )
                }
            }
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading) {
                    Text("Squares at peak: \(Int(squaresMin))")
                        .font(.caption)
                    Slider(value: $squaresMin, in: 2.0...50.0, step: 1.0)
                }
                
                VStack(alignment: .leading) {
                    Text("Steps: \(Int(steps))")
                        .font(.caption)
                    Slider(value: $steps, in: 5.0...50.0, step: 1.0)
                        .disabled(smoothTransition)
                }
                
                Toggle("Smooth Transition", isOn: $smoothTransition)
                    .font(.caption)
                
                HStack(spacing: 10) {
                    Button("Subtle") {
                        squaresMin = 40.0
                        steps = 10.0
                        smoothTransition = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Default") {
                        squaresMin = 20.0
                        steps = 20.0
                        smoothTransition = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Chunky") {
                        squaresMin = 8.0
                        steps = 30.0
                        smoothTransition = false
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
        .navigationTitle("Pixelize")
    }
}

#Preview {
    PixelizeView()
}
