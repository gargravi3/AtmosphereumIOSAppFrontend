import SwiftUI

// Lightweight confetti — pure SwiftUI, no 3rd-party dependencies.
// Trigger by mutating a state value passed into `trigger:`. Each change
// (even from 0 to 1) kicks off a single burst and auto-fades out.
// Particles are drawn above the content via .overlay; the view never
// blocks hit-testing so buttons underneath keep responding.
struct ConfettiBurst: View {
    let trigger: Int
    var count: Int = 28

    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        let color: Color
        let xStart: CGFloat
        let xEnd: CGFloat
        let yEnd: CGFloat
        let rotationEnd: Double
        let shape: Shape
        let delay: Double
        enum Shape { case square, circle, triangle }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    ParticleView(p: p, size: geo.size)
                }
            }
            .allowsHitTesting(false)
        }
        .onChange(of: trigger) { _, _ in spawn() }
    }

    private func spawn() {
        let palette: [Color] = [
            AppColor.primaryNavy,
            AppColor.primaryGreen,
            AppColor.chartRed,
            AppColor.chartOrange,
            AppColor.chartPurple,
            AppColor.chartGreen,
            .yellow
        ]
        let shapes: [Particle.Shape] = [.square, .circle, .triangle]
        particles = (0..<count).map { _ in
            Particle(
                color: palette.randomElement()!,
                xStart: CGFloat.random(in: 0.35...0.65),
                xEnd: CGFloat.random(in: 0.0...1.0),
                yEnd: CGFloat.random(in: 0.65...1.05),
                rotationEnd: Double.random(in: -540...540),
                shape: shapes.randomElement()!,
                delay: Double.random(in: 0...0.12)
            )
        }
        // Clear particles after animation settles so we don't leak views.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            particles.removeAll()
        }
    }
}

private struct ParticleView: View {
    let p: ConfettiBurst.Particle
    let size: CGSize

    @State private var animated = false

    var body: some View {
        shapeView
            .frame(width: 8, height: 8)
            .foregroundStyle(p.color)
            .rotationEffect(.degrees(animated ? p.rotationEnd : 0))
            .position(
                x: animated ? p.xEnd * size.width : p.xStart * size.width,
                y: animated ? p.yEnd * size.height : 0
            )
            .opacity(animated ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 1.4).delay(p.delay)) {
                    animated = true
                }
            }
    }

    @ViewBuilder
    private var shapeView: some View {
        switch p.shape {
        case .square:   Rectangle()
        case .circle:   Circle()
        case .triangle: Triangle()
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
