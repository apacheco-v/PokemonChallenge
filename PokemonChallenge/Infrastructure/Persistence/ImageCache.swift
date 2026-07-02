import UIKit

final class ImageCache {
    static let shared = ImageCache()

    private let fileManager: FileManager
    private let cacheDirectory: URL

    private init() {
        fileManager = FileManager.default
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = caches.appendingPathComponent("image_cache", isDirectory: true)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    private func fileURL(for id: Int) -> URL {
        cacheDirectory.appendingPathComponent("\(id).png")
    }

    func get(for id: Int) -> UIImage? {
        let url = fileURL(for: id)
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func set(data: Data, for id: Int) {
        let url = fileURL(for: id)
        try? data.write(to: url)
    }
}
