import UIKit
import OSLog

final class ImageCache {
    static let shared = ImageCache()

    private let fileManager: FileManager
    private let cacheDirectory: URL
    private let maxDiskSize: Int
    private let logger = Logger(subsystem: "com.pokemonchallenge", category: "imagecache")

    init(maxDiskSize: Int = 50_000_000) {
        self.fileManager = FileManager.default
        self.maxDiskSize = maxDiskSize
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
        do {
            try data.write(to: url)
            enforceDiskLimit()
        } catch {
            logger.error("Failed to cache image \(id): \(error.localizedDescription)")
        }
    }

    private func enforceDiskLimit() {
        guard let enumerator = fileManager.enumerator(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]
        ) else { return }

        var files: [(url: URL, size: Int, date: Date)] = []
        var totalSize = 0

        for case let fileURL as URL in enumerator {
            guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                  let size = attributes[.size] as? Int,
                  let date = attributes[.modificationDate] as? Date else { continue }
            files.append((fileURL, size, date))
            totalSize += size
        }

        guard totalSize > maxDiskSize else { return }

        let sorted = files.sorted { $0.date < $1.date }
        var overshoot = totalSize - maxDiskSize

        for file in sorted {
            guard overshoot > 0 else { break }
            try? fileManager.removeItem(at: file.url)
            overshoot -= file.size
        }

        let evicted = sorted.filter { !self.fileManager.fileExists(atPath: $0.url.path) }.count
        logger.notice("Evicted \(evicted) images (\(totalSize - max(totalSize - overshoot, 0)) bytes)")
    }

    func clear() {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else { return }
        for file in files { try? fileManager.removeItem(at: file) }
        logger.notice("Image cache cleared")
    }
}
