import SwiftUI

/// A short-lived confetti burst. Set `trigger` to true to fire it once;
/// pieces animate outward and fade automatically.
struct ConfettiView: View {
    @Binding var trigger: Bool
    private let emojis = ["🍓", "🍍", "🥭", "🍇", "🍊", "⭐️", "🍒"]

    var body: some View {
        ZStack {
            if trigger {
                ForEach(0..<24, id: \.self) { index in
                    ConfettiPiece(emoji: emojis[index % emojis.count])
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: View {
    let emoji: String
    @State private var animate = false
    @State private var randomX = CGFloat.random(in: -140...140)
    @State private var randomY = CGFloat.random(in: -320 ... -60)
    @State private var randomRotation = Double.random(in: -180...180)

    var body: some View {
        Text(emoji)
            .font(.system(size: 22))
            .offset(x: animate ? randomX : 0, y: animate ? randomY : 0)
            .rotationEffect(.degrees(animate ? randomRotation : 0))
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 1.1)) {
                    animate = true
                }
            }
    }
}
