import XCTest
import Magnet
import Carbon
@testable import Clipy2

final class HotKeyServiceTests: XCTestCase {

    let defaults = UserDefaults.standard

    override func tearDown() {
        defaults.removeObject(forKey: Constants.UserDefaults.hotKeys)
        defaults.removeObject(forKey: Constants.HotKey.migrateNewKeyCombo)
        defaults.removeObject(forKey: Constants.HotKey.mainKeyCombo)
        defaults.removeObject(forKey: Constants.HotKey.historyKeyCombo)
        defaults.removeObject(forKey: Constants.HotKey.snippetKeyCombo)
        defaults.removeObject(forKey: Constants.HotKey.clearHistoryKeyCombo)
        defaults.removeObject(forKey: Constants.HotKey.folderKeyCombos)
        defaults.synchronize()
        super.tearDown()
    }

    // MARK: - Migrate HotKey Tests

    func testMigrateDefaultSettings() throws {
        let service = HotKeyService()
        XCTAssertNil(service.mainKeyCombo)
        XCTAssertNil(service.historyKeyCombo)
        XCTAssertNil(service.snippetKeyCombo)

        XCTAssertFalse(defaults.bool(forKey: Constants.HotKey.migrateNewKeyCombo))
        service.setupDefaultHotKeys()
        XCTAssertTrue(defaults.bool(forKey: Constants.HotKey.migrateNewKeyCombo))

        let mainCombo = try XCTUnwrap(service.mainKeyCombo)
        XCTAssertEqual(mainCombo.QWERTYKeyCode, 9)
        XCTAssertEqual(mainCombo.modifiers, 768)
        XCTAssertFalse(mainCombo.doubledModifiers)
        XCTAssertEqual(mainCombo.keyEquivalent.uppercased(), "V")

        let historyCombo = try XCTUnwrap(service.historyKeyCombo)
        XCTAssertEqual(historyCombo.QWERTYKeyCode, 9)
        XCTAssertEqual(historyCombo.modifiers, 4352)
        XCTAssertFalse(historyCombo.doubledModifiers)
        XCTAssertEqual(historyCombo.keyEquivalent.uppercased(), "V")

        let snippetCombo = try XCTUnwrap(service.snippetKeyCombo)
        XCTAssertEqual(snippetCombo.QWERTYKeyCode, 11)
        XCTAssertEqual(snippetCombo.modifiers, 768)
        XCTAssertFalse(snippetCombo.doubledModifiers)
        XCTAssertEqual(snippetCombo.keyEquivalent.uppercased(), "B")
    }

    func testMigrateCustomizeSettings() throws {
        let service = HotKeyService()
        XCTAssertNil(service.mainKeyCombo)
        XCTAssertNil(service.historyKeyCombo)
        XCTAssertNil(service.snippetKeyCombo)

        let defaultKeyCombos: [String: Any] = [
            Constants.Menu.clip: ["keyCode": 0, "modifiers": 4352],
            Constants.Menu.history: ["keyCode": 9, "modifiers": 768],
            Constants.Menu.snippet: ["keyCode": 11, "modifiers": 4352]
        ]
        defaults.set(defaultKeyCombos, forKey: Constants.UserDefaults.hotKeys)
        defaults.synchronize()

        XCTAssertFalse(defaults.bool(forKey: Constants.HotKey.migrateNewKeyCombo))
        service.setupDefaultHotKeys()
        XCTAssertTrue(defaults.bool(forKey: Constants.HotKey.migrateNewKeyCombo))

        let mainCombo = try XCTUnwrap(service.mainKeyCombo)
        XCTAssertEqual(mainCombo.QWERTYKeyCode, 0)
        XCTAssertEqual(mainCombo.modifiers, 4352)
        XCTAssertFalse(mainCombo.doubledModifiers)
        XCTAssertEqual(mainCombo.keyEquivalent.uppercased(), "A")

        let historyCombo = try XCTUnwrap(service.historyKeyCombo)
        XCTAssertEqual(historyCombo.QWERTYKeyCode, 9)
        XCTAssertEqual(historyCombo.modifiers, 768)
        XCTAssertFalse(historyCombo.doubledModifiers)
        XCTAssertEqual(historyCombo.keyEquivalent.uppercased(), "V")

        let snippetCombo = try XCTUnwrap(service.snippetKeyCombo)
        XCTAssertEqual(snippetCombo.QWERTYKeyCode, 11)
        XCTAssertEqual(snippetCombo.modifiers, 4352)
        XCTAssertFalse(snippetCombo.doubledModifiers)
        XCTAssertEqual(snippetCombo.keyEquivalent.uppercased(), "B")
    }

    // MARK: - Save HotKey Tests

    func testSaveKeyCombos() throws {
        defaults.set(true, forKey: Constants.HotKey.migrateNewKeyCombo)

        let service = HotKeyService()
        XCTAssertNil(service.mainKeyCombo)
        XCTAssertNil(service.historyKeyCombo)
        XCTAssertNil(service.snippetKeyCombo)

        XCTAssertNil(defaults.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.mainKeyCombo))
        XCTAssertNil(defaults.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.historyKeyCombo))
        XCTAssertNil(defaults.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.snippetKeyCombo))

        service.setupDefaultHotKeys()
        XCTAssertNil(service.mainKeyCombo)
        XCTAssertNil(service.historyKeyCombo)
        XCTAssertNil(service.snippetKeyCombo)

        let mainKeyCombo = KeyCombo(QWERTYKeyCode: 9, carbonModifiers: 768)
        let historyKeyCombo = KeyCombo(doubledCocoaModifiers: .command)
        let snippetKeyCombo = KeyCombo(QWERTYKeyCode: 0, cocoaModifiers: .shift)

        service.change(with: .main, keyCombo: mainKeyCombo)
        service.change(with: .history, keyCombo: historyKeyCombo)
        service.change(with: .snippet, keyCombo: snippetKeyCombo)

        let savedMainKeyCombo = try XCTUnwrap(defaults.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.mainKeyCombo))
        XCTAssertEqual(savedMainKeyCombo.QWERTYKeyCode, 9)
        XCTAssertEqual(savedMainKeyCombo.modifiers, 768)
        XCTAssertFalse(savedMainKeyCombo.doubledModifiers)
        XCTAssertEqual(savedMainKeyCombo.keyEquivalent.uppercased(), "V")

        let savedHistoryKeyCombo = try XCTUnwrap(defaults.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.historyKeyCombo))
        XCTAssertEqual(savedHistoryKeyCombo.QWERTYKeyCode, 0)
        XCTAssertEqual(savedHistoryKeyCombo.modifiers, cmdKey)
        XCTAssertTrue(savedHistoryKeyCombo.doubledModifiers)
        XCTAssertEqual(savedHistoryKeyCombo.keyEquivalent.uppercased(), "")

        let savedSnippetKeyCombo = try XCTUnwrap(defaults.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.snippetKeyCombo))
        XCTAssertEqual(savedSnippetKeyCombo.QWERTYKeyCode, 0)
        XCTAssertEqual(savedSnippetKeyCombo.modifiers, shiftKey)
        XCTAssertFalse(savedSnippetKeyCombo.doubledModifiers)
        XCTAssertEqual(savedSnippetKeyCombo.keyEquivalent.uppercased(), "A")

        service.change(with: .main, keyCombo: nil)
        XCTAssertNil(service.mainKeyCombo)
        XCTAssertNil(defaults.archiveDataForKey(KeyCombo.self, key: Constants.HotKey.mainKeyCombo))
    }

    func testUnarchiveSavedKeyCombos() throws {
        defaults.set(true, forKey: Constants.HotKey.migrateNewKeyCombo)

        let mainKeyCombo = try XCTUnwrap(KeyCombo(QWERTYKeyCode: 9, carbonModifiers: 768))
        let historyKeyCombo = try XCTUnwrap(KeyCombo(doubledCocoaModifiers: .command))
        let snippetKeyCombo = try XCTUnwrap(KeyCombo(QWERTYKeyCode: 0, cocoaModifiers: .shift))

        defaults.setArchiveData(mainKeyCombo, forKey: Constants.HotKey.mainKeyCombo)
        defaults.setArchiveData(historyKeyCombo, forKey: Constants.HotKey.historyKeyCombo)
        defaults.setArchiveData(snippetKeyCombo, forKey: Constants.HotKey.snippetKeyCombo)

        let service = HotKeyService()
        XCTAssertNil(service.mainKeyCombo)
        XCTAssertNil(service.historyKeyCombo)
        XCTAssertNil(service.snippetKeyCombo)

        service.setupDefaultHotKeys()

        let savedMainCombo = try XCTUnwrap(service.mainKeyCombo)
        XCTAssertEqual(savedMainCombo.QWERTYKeyCode, 9)
        XCTAssertEqual(savedMainCombo.modifiers, 768)
        XCTAssertFalse(savedMainCombo.doubledModifiers)
        XCTAssertEqual(savedMainCombo.keyEquivalent.uppercased(), "V")

        let savedHistoryCombo = try XCTUnwrap(service.historyKeyCombo)
        XCTAssertEqual(savedHistoryCombo.QWERTYKeyCode, 0)
        XCTAssertEqual(savedHistoryCombo.modifiers, cmdKey)
        XCTAssertTrue(savedHistoryCombo.doubledModifiers)
        XCTAssertEqual(savedHistoryCombo.keyEquivalent.uppercased(), "")

        let savedSnippetCombo = try XCTUnwrap(service.snippetKeyCombo)
        XCTAssertEqual(savedSnippetCombo.QWERTYKeyCode, 0)
        XCTAssertEqual(savedSnippetCombo.modifiers, shiftKey)
        XCTAssertFalse(savedSnippetCombo.doubledModifiers)
        XCTAssertEqual(savedSnippetCombo.keyEquivalent.uppercased(), "A")
    }

    // MARK: - Key Combos Tests

    func testDefaultKeyCombos() throws {
        let keyCombos = HotKeyService.defaultKeyCombos
        let mainCombos = try XCTUnwrap(keyCombos[Constants.Menu.clip] as? [String: Int])
        let historyCombos = try XCTUnwrap(keyCombos[Constants.Menu.history] as? [String: Int])
        let snippetCombos = try XCTUnwrap(keyCombos[Constants.Menu.snippet] as? [String: Int])

        XCTAssertEqual(mainCombos["keyCode"], 9)
        XCTAssertEqual(mainCombos["modifiers"], 768)

        XCTAssertEqual(historyCombos["keyCode"], 9)
        XCTAssertEqual(historyCombos["modifiers"], 4352)

        XCTAssertEqual(snippetCombos["keyCode"], 11)
        XCTAssertEqual(snippetCombos["modifiers"], 768)
    }

    // MARK: - Clear History HotKey Tests

    func testAddAndRemoveClearHistoryHotkey() throws {
        let service = HotKeyService()

        XCTAssertNil(service.clearHistoryKeyCombo)

        let keyCombo = try XCTUnwrap(KeyCombo(QWERTYKeyCode: 10, carbonModifiers: cmdKey))
        service.changeClearHistoryKeyCombo(keyCombo)

        XCTAssertNotNil(service.clearHistoryKeyCombo)
        XCTAssertEqual(service.clearHistoryKeyCombo, keyCombo)

        let savedData = try XCTUnwrap(defaults.object(forKey: Constants.HotKey.clearHistoryKeyCombo) as? Data)
        let savedKeyCombo = try XCTUnwrap(NSKeyedUnarchiver.unarchiveObject(with: savedData) as? KeyCombo)
        XCTAssertEqual(savedKeyCombo, keyCombo)

        service.changeClearHistoryKeyCombo(nil)
        XCTAssertNil(service.clearHistoryKeyCombo)
    }

    // MARK: - Folder HotKey Tests

    func testAddAndRemoveFolderHotkey() throws {
        let service = HotKeyService()

        let identifier = NSUUID().uuidString
        XCTAssertNil(service.snippetKeyCombo(forIdentifier: identifier))

        let keyCombo = try XCTUnwrap(KeyCombo(QWERTYKeyCode: 0, carbonModifiers: cmdKey))
        service.registerSnippetHotKey(with: identifier, keyCombo: keyCombo)

        XCTAssertNotNil(service.snippetKeyCombo(forIdentifier: identifier))
        XCTAssertEqual(service.snippetKeyCombo(forIdentifier: identifier), keyCombo)

        let changeKeyCombo = try XCTUnwrap(KeyCombo(doubledCarbonModifiers: shiftKey))
        service.registerSnippetHotKey(with: identifier, keyCombo: changeKeyCombo)

        XCTAssertNotEqual(service.snippetKeyCombo(forIdentifier: identifier), keyCombo)
        XCTAssertEqual(service.snippetKeyCombo(forIdentifier: identifier), changeKeyCombo)

        service.unregisterSnippetHotKey(with: identifier)
        XCTAssertNil(service.snippetKeyCombo(forIdentifier: identifier))
    }
}
