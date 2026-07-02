import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("Pokémon")
                    .font(.largeTitle.weight(.bold))

                Text("Challenge")
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            VStack {
                Spacer()
                Text("Created by Alexis Pacheco")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }
}

#Preview {
    SplashScreenView()
}
