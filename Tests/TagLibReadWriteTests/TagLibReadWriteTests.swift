import XCTest
import TagLibBridge

final class TagLibReadWriteTests: XCTestCase {
    private let titleKey = "title"
    private let artistKey = "artist"
    private let albumKey = "album"
    private let albumArtistKey = "albumArtist"
    private let composerKey = "composer"
    private let yearKey = "year"
    private let genreKey = "genre"
    private let trackNumberKey = "trackNumber"
    private let trackTotalKey = "trackTotal"

    func testMP3ReadWriteRoundTrip() throws {
        try roundTrip(exts: ["mp3"])
    }

    func testMP4ReadWriteRoundTrip() throws {
        try roundTrip(exts: ["m4a", "mp4", "aac", "m4b", "m4v"])
    }

    func testApplyLookupWritesFields() throws {
        guard let url = fixtureURL(exts: ["mp3"]) else {
            throw XCTSkip("Missing MP3 fixtures under ~/Music/test (or TAGLIB_TEST_FIXTURES).")
        }
        let tmp = try copyToTemp(url: url, suffix: "lookup")
        defer { try? FileManager.default.removeItem(at: tmp) }

        let tags: [String: Any] = [
            titleKey: "Lookup Title",
            artistKey: "Lookup Artist",
            albumKey: "Lookup Album",
            albumArtistKey: "Lookup Album Artist",
            composerKey: "Lookup Composer",
            yearKey: 2024,
            genreKey: "Rock",
            trackNumberKey: 5,
            trackTotalKey: 12
        ]
        try write(path: tmp.path, tags: tags)
        let readBack = try read(path: tmp.path)

        XCTAssertEqual(readBack[titleKey] as? String, tags[titleKey] as? String)
        XCTAssertEqual(readBack[artistKey] as? String, tags[artistKey] as? String)
        XCTAssertEqual(readBack[albumKey] as? String, tags[albumKey] as? String)
        XCTAssertEqual(readBack[albumArtistKey] as? String, tags[albumArtistKey] as? String)
        XCTAssertEqual(readBack[composerKey] as? String, tags[composerKey] as? String)
        XCTAssertEqual(readBack[genreKey] as? String, tags[genreKey] as? String)
        XCTAssertEqual(intValue(readBack[trackNumberKey]), 5)
        XCTAssertEqual(intValue(readBack[trackTotalKey]), 12)
    }

    // MARK: - Helpers
    private func roundTrip(exts: [String]) throws {
        guard let url = fixtureURL(exts: exts) else {
            throw XCTSkip("Missing fixtures for \(exts.joined(separator: ", ")) under ~/Music/test (or TAGLIB_TEST_FIXTURES).")
        }
        let tmp = try copyToTemp(url: url, suffix: "rt")
        defer { try? FileManager.default.removeItem(at: tmp) }

        var tags = try read(path: tmp.path)
        let newTitle = "TestTitle-\(UUID().uuidString.prefix(6))"
        tags[titleKey] = newTitle
        tags[artistKey] = "TestArtist"
        tags[albumKey] = "TestAlbum"
        tags[genreKey] = "TestGenre"
        tags[yearKey] = 2025
        try write(path: tmp.path, tags: tags)

        let reread = try read(path: tmp.path)
        XCTAssertEqual(reread[titleKey] as? String, newTitle)
        XCTAssertEqual(reread[artistKey] as? String, tags[artistKey] as? String)
        XCTAssertEqual(reread[albumKey] as? String, tags[albumKey] as? String)
        XCTAssertEqual(reread[genreKey] as? String, tags[genreKey] as? String)
        XCTAssertEqual(intValue(reread[yearKey]), intValue(tags[yearKey]))
    }

    private func read(path: String) throws -> [String: Any] {
        var err: NSError?
        let result = TagLibBridge.readTags(atPath: path, error: &err)
        if let err { throw err }
        return result as? [String: Any] ?? [:]
    }

    private func write(path: String, tags: [String: Any]) throws {
        try TagLibBridge.writeTags(atPath: path, tags: tags)
    }

    private func intValue(_ value: Any?) -> Int? {
        if let num = value as? NSNumber { return num.intValue }
        return value as? Int
    }

    private func fixtureURL(exts: [String]) -> URL? {
        let envPath = ProcessInfo.processInfo.environment["TAGLIB_TEST_FIXTURES"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        let root: URL
        if let envPath, !envPath.isEmpty {
            root = URL(fileURLWithPath: (envPath as NSString).expandingTildeInPath)
        } else {
            root = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Music/test")
        }
        return firstFixture(in: root, exts: exts)
    }

    private func firstFixture(in root: URL, exts: [String]) -> URL? {
        let fm = FileManager.default
        for ext in exts {
            let dir = root.appendingPathComponent(ext)
            if let file = firstFile(in: dir, exts: [ext]) {
                return file
            }
        }
        return firstFile(in: root, exts: exts)
    }

    private func firstFile(in root: URL, exts: [String]) -> URL? {
        let keys: [URLResourceKey] = [.isRegularFileKey]
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }
        let set = Set(exts.map { $0.lowercased() })
        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: Set(keys)),
                  values.isRegularFile == true else {
                continue
            }
            if set.contains(url.pathExtension.lowercased()) {
                return url
            }
        }
        return nil
    }

    private func copyToTemp(url: URL, suffix: String) throws -> URL {
        let dir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TagLibTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let dest = dir.appendingPathComponent(url.lastPathComponent + "-\(suffix)")
        try FileManager.default.copyItem(at: url, to: dest)
        return dest
    }
}
