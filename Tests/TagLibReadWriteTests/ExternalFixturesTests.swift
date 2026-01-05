import XCTest
import TagLibBridge

final class ExternalFixturesTests: XCTestCase {
    func testExternalFixturesRoundTrip() throws {
        guard let root = externalFixturesRoot() else {
            throw XCTSkip("No external fixtures found. Set TAGLIB_TEST_FIXTURES or place files under ~/Music/test.")
        }

        let urls = collectAudioFiles(in: root)
        if urls.isEmpty {
            throw XCTSkip("No audio files found under \(root.path).")
        }

        for url in urls.sorted(by: { $0.path < $1.path }) {
            XCTContext.runActivity(named: url.lastPathComponent) { _ in
                do {
                    try roundTrip(url: url)
                } catch {
                    XCTFail("Round trip failed for \(url.path): \(error.localizedDescription)")
                }
            }
        }
    }
}

private func externalFixturesRoot() -> URL? {
    let envPath = ProcessInfo.processInfo.environment["TAGLIB_TEST_FIXTURES"]?.trimmingCharacters(in: .whitespacesAndNewlines)
    if let envPath, !envPath.isEmpty {
        return URL(fileURLWithPath: (envPath as NSString).expandingTildeInPath)
    }

    let home = FileManager.default.homeDirectoryForCurrentUser
    let defaultRoot = home.appendingPathComponent("Music/test")
    if FileManager.default.fileExists(atPath: defaultRoot.path) {
        return defaultRoot
    }

    return nil
}

private func collectAudioFiles(in root: URL) -> [URL] {
    let supported = Set([
        "mp3", "m4a", "mp4", "aac", "flac", "ogg", "opus", "wav", "aif", "aiff", "wv", "mpc", "dsf"
    ])
    let keys: [URLResourceKey] = [.isRegularFileKey]
    guard let enumerator = FileManager.default.enumerator(
        at: root,
        includingPropertiesForKeys: keys,
        options: [.skipsHiddenFiles]
    ) else {
        return []
    }

    var results: [URL] = []
    for case let url as URL in enumerator {
        guard let values = try? url.resourceValues(forKeys: Set(keys)),
              values.isRegularFile == true else {
            continue
        }
        let ext = url.pathExtension.lowercased()
        if supported.contains(ext) {
            results.append(url)
        }
    }
    return results
}

private func roundTrip(url: URL) throws {
    let tmp = try copyToTemp(url: url)
    defer { try? FileManager.default.removeItem(at: tmp) }

    let ext = tmp.pathExtension.lowercased()
    let tags = buildTags(forExtension: ext)

    do {
        try TagLibBridge.writeTags(atPath: tmp.path, tags: tags)
    } catch {
        throw error
    }

    var readError: NSError?
    let readBack = TagLibBridge.readTags(atPath: tmp.path, error: &readError)
    if let readError {
        throw readError
    }

    assertTag(readBack, key: "title", expected: tags["title"])
    assertTag(readBack, key: "artist", expected: tags["artist"])
    assertTag(readBack, key: "album", expected: tags["album"])
    assertTag(readBack, key: "genre", expected: tags["genre"])
    assertTag(readBack, key: "trackNumber", expected: tags["trackNumber"])
    assertTag(readBack, key: "year", expected: tags["year"])
}

private func buildTags(forExtension ext: String) -> [String: Any] {
    let seed = UUID().uuidString.prefix(6)
    let baseTags: [String: Any] = [
        "title": "TL Test \(seed)",
        "artist": "TagLib Test Artist",
        "album": "TagLib Test Album",
        "genre": "Rock",
        "trackNumber": 7
    ]

    var tags = baseTags
    tags["year"] = 2024
    return tags
}

private func assertTag(_ tags: [AnyHashable: Any], key: String, expected: Any?) {
    guard let expected else { return }

    if let expectedString = expected as? String {
        let actual = tags[key] as? String
        if actual == nil, let num = tags[key] as? NSNumber, let expectedInt = Int(expectedString) {
            XCTAssertEqual(num.intValue, expectedInt, "Mismatch for \(key)")
            return
        }
        XCTAssertEqual(actual, expectedString, "Mismatch for \(key)")
        return
    }

    if let expectedInt = expected as? Int {
        let actual = (tags[key] as? NSNumber)?.intValue ?? (tags[key] as? Int)
        XCTAssertEqual(actual, expectedInt, "Mismatch for \(key)")
    }
}

private func copyToTemp(url: URL) throws -> URL {
    let dir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TagLibTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let dest = dir.appendingPathComponent(url.lastPathComponent)
    try FileManager.default.copyItem(at: url, to: dest)
    return dest
}
