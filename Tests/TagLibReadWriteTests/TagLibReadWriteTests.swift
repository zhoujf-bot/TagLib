import XCTest
import TagLibTestSupport

final class TagLibReadWriteTests: XCTestCase {
    func testMP3ReadWriteRoundTrip() throws {
        try roundTrip(fixture: "sample_mp3")
    }

    func testMP4ReadWriteRoundTrip() throws {
        try roundTrip(fixture: "sample_m4a")
    }

    func testApplyLookupWritesFields() throws {
        guard let url = fixtureURL(named: "sample_mp3") else {
            throw XCTSkip("Missing fixture sample_mp3; run scripts/fetch-fixtures.sh (edit scripts/fixtures-sources.json if needed).")
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
    private func roundTrip(fixture: String) throws {
        guard let url = fixtureURL(named: fixture) else {
            throw XCTSkip("Missing fixture \(fixture); run scripts/fetch-fixtures.sh (edit scripts/fixtures-sources.json if needed).")
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

    private func fixtureURL(named name: String) -> URL? {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // file
            .deletingLastPathComponent() // TagLibReadWriteTests
            .deletingLastPathComponent() // Tests
        let base = root.appendingPathComponent("Tests/Fixtures")
        let direct = base.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: direct.path) { return direct }
        let exts = ["mp3", "m4a", "mp4", "flac", "ogg", "opus", "wav", "aif", "aiff", "wv", "mpc", "dsf"]
        for ext in exts {
            let candidate = direct.appendingPathExtension(ext)
            if FileManager.default.fileExists(atPath: candidate.path) {
                return candidate
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
