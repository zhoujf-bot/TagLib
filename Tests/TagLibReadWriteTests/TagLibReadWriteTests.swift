import XCTest
import TagLibTestSupport

final class TagLibReadWriteTests: XCTestCase {
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
            kTLTestTitleKey: "Lookup Title",
            kTLTestArtistKey: "Lookup Artist",
            kTLTestAlbumKey: "Lookup Album",
            kTLTestAlbumArtistKey: "Lookup Album Artist",
            kTLTestComposerKey: "Lookup Composer",
            kTLTestYearKey: 2024,
            kTLTestGenreKey: "Rock",
            kTLTestTrackNumberKey: 5,
            kTLTestTrackTotalKey: 12
        ]
        try write(path: tmp.path, tags: tags)
        let readBack = try read(path: tmp.path)

        XCTAssertEqual(readBack[kTLTestTitleKey] as? String, tags[kTLTestTitleKey] as? String)
        XCTAssertEqual(readBack[kTLTestArtistKey] as? String, tags[kTLTestArtistKey] as? String)
        XCTAssertEqual(readBack[kTLTestAlbumKey] as? String, tags[kTLTestAlbumKey] as? String)
        XCTAssertEqual(readBack[kTLTestAlbumArtistKey] as? String, tags[kTLTestAlbumArtistKey] as? String)
        XCTAssertEqual(readBack[kTLTestComposerKey] as? String, tags[kTLTestComposerKey] as? String)
        XCTAssertEqual(readBack[kTLTestGenreKey] as? String, tags[kTLTestGenreKey] as? String)
        XCTAssertEqual(intValue(readBack[kTLTestTrackNumberKey]), 5)
        XCTAssertEqual(intValue(readBack[kTLTestTrackTotalKey]), 12)
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
        tags[kTLTestTitleKey] = newTitle
        tags[kTLTestArtistKey] = "TestArtist"
        tags[kTLTestAlbumKey] = "TestAlbum"
        tags[kTLTestGenreKey] = "TestGenre"
        tags[kTLTestYearKey] = 2025
        try write(path: tmp.path, tags: tags)

        let reread = try read(path: tmp.path)
        XCTAssertEqual(reread[kTLTestTitleKey] as? String, newTitle)
        XCTAssertEqual(reread[kTLTestArtistKey] as? String, tags[kTLTestArtistKey] as? String)
        XCTAssertEqual(reread[kTLTestAlbumKey] as? String, tags[kTLTestAlbumKey] as? String)
        XCTAssertEqual(reread[kTLTestGenreKey] as? String, tags[kTLTestGenreKey] as? String)
        XCTAssertEqual(intValue(reread[kTLTestYearKey]), intValue(tags[kTLTestYearKey]))
    }

    private func read(path: String) throws -> [String: Any] {
        var err: NSError?
        let result = TLTestReadTags(path, &err)
        if let err {
            throw err
        }
        return result
    }

    private func write(path: String, tags: [String: Any]) throws {
        var err: NSError?
        let ok = TLTestWriteTags(path, tags, &err)
        if !ok {
            throw err ?? NSError(domain: "TagLibTest", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unknown write error"])
        }
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
