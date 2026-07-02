import UIKit
import SwiftUI

struct CachedPokemonImage: View {
    let id: Int
    let size: CGFloat

    @State private var uiImage: UIImage?
    @State private var didFail = false

    private var url: URL {
        URL(string: "\(APIConstants.spriteBaseURL)/\(id).png")!
    }

    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            } else if didFail {
                fallback
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .task(id: id) {
            await loadImage()
        }
    }

    private func loadImage() async {
        didFail = false

        if let cached = ImageCache.shared.get(for: id) {
            uiImage = cached
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            ImageCache.shared.set(data: data, for: id)
            uiImage = UIImage(data: data)
        } catch {
            didFail = true
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.gray.opacity(0.15))
            .frame(width: size, height: size)
            .shimmer()
    }

    private var fallback: some View {
        Image(systemName: "photo.badge.exclamationmark")
            .font(.title3)
            .foregroundStyle(.secondary)
            .frame(width: size, height: size)
    }
}
