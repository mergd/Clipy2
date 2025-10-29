import XCTest
import RealmSwift
@testable import Clipy

final class FolderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = NSUUID().uuidString
    }

    override func tearDown() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        super.tearDown()
    }

    // MARK: - Create New Tests

    func testDeepCopyObject() throws {
        let savedFolder = CPYFolder()
        savedFolder.index = 100
        savedFolder.title = "saved realm folder"

        let savedSnippet = CPYSnippet()
        savedSnippet.index = 10
        savedSnippet.title = "saved realm snippet"
        savedSnippet.content = "content"
        savedFolder.snippets.append(savedSnippet)

        let realm = try Realm()
        try realm.write {
            realm.add(savedFolder)
        }

        XCTAssertNotNil(savedFolder.realm)
        XCTAssertNotNil(savedSnippet.realm)

        let folder = savedFolder.deepCopy()
        XCTAssertNil(folder.realm)
        XCTAssertEqual(folder.index, savedFolder.index)
        XCTAssertEqual(folder.enable, savedFolder.enable)
        XCTAssertEqual(folder.title, savedFolder.title)
        XCTAssertEqual(folder.identifier, savedFolder.identifier)
        XCTAssertEqual(folder.snippets.count, 1)

        let snippet = try XCTUnwrap(folder.snippets.first)
        XCTAssertNil(snippet.realm)
        XCTAssertEqual(snippet.index, savedSnippet.index)
        XCTAssertEqual(snippet.enable, savedSnippet.enable)
        XCTAssertEqual(snippet.title, savedSnippet.title)
        XCTAssertEqual(snippet.content, savedSnippet.content)
        XCTAssertEqual(snippet.identifier, savedSnippet.identifier)
    }

    func testCreateFolder() throws {
        let folder = CPYFolder.create()
        XCTAssertEqual(folder.title, "untitled folder")
        XCTAssertEqual(folder.index, 0)

        let realm = try Realm()
        try realm.write {
            realm.add(folder)
        }

        let folder2 = CPYFolder.create()
        XCTAssertEqual(folder2.index, 1)
    }

    func testCreateSnippet() throws {
        let folder = CPYFolder()
        let snippet = folder.createSnippet()

        XCTAssertEqual(snippet.title, "untitled snippet")
        XCTAssertEqual(snippet.index, 0)

        folder.snippets.append(snippet)

        let snippet2 = folder.createSnippet()
        XCTAssertEqual(snippet2.index, 1)
    }

    // MARK: - Sync Database Tests

    func testMergeSnippet() throws {
        let folder = CPYFolder()
        let realm = try Realm()
        try realm.write {
            realm.add(folder)
        }
        let copyFolder = folder.deepCopy()

        let snippet = CPYSnippet()
        let snippet2 = CPYSnippet()
        copyFolder.mergeSnippet(snippet)
        copyFolder.mergeSnippet(snippet2)

        XCTAssertNil(snippet.realm)
        XCTAssertNil(snippet2.realm)
        XCTAssertEqual(folder.snippets.count, 2)

        let savedSnippet = try XCTUnwrap(folder.snippets.first)
        let savedSnippet2 = folder.snippets[1]
        XCTAssertEqual(savedSnippet.identifier, snippet.identifier)
        XCTAssertEqual(savedSnippet2.identifier, snippet2.identifier)
    }

    func testInsertSnippet() throws {
        let folder = CPYFolder()
        let realm = try Realm()
        try realm.write {
            realm.add(folder)
        }
        let copyFolder = folder.deepCopy()

        let snippet = CPYSnippet()
        copyFolder.insertSnippet(snippet, index: 0)
        XCTAssertEqual(folder.snippets.count, 0)

        try realm.write {
            realm.add(snippet)
        }

        copyFolder.insertSnippet(snippet, index: 0)
        XCTAssertEqual(folder.snippets.count, 1)
    }

    func testRemoveSnippet() throws {
        let folder = CPYFolder()
        let snippet = CPYSnippet()
        folder.snippets.append(snippet)
        let realm = try Realm()
        try realm.write {
            realm.add(folder)
        }

        XCTAssertEqual(folder.snippets.count, 1)

        let copyFolder = folder.deepCopy()
        copyFolder.removeSnippet(snippet)

        XCTAssertEqual(folder.snippets.count, 0)
    }

    func testMergeFolder() throws {
        let realm = try Realm()
        XCTAssertEqual(realm.objects(CPYFolder.self).count, 0)

        let folder = CPYFolder()
        folder.index = 100
        folder.title = "title"
        folder.enable = false
        folder.merge()

        XCTAssertNil(folder.realm)
        XCTAssertEqual(realm.objects(CPYFolder.self).count, 1)

        let savedFolder = realm.object(ofType: CPYFolder.self, forPrimaryKey: folder.identifier)
        XCTAssertNotNil(savedFolder)
        XCTAssertEqual(savedFolder?.index, folder.index)
        XCTAssertEqual(savedFolder?.title, folder.title)
        XCTAssertEqual(savedFolder?.enable, folder.enable)

        folder.index = 1
        folder.title = "change title"
        folder.enable = true
        folder.merge()
        XCTAssertEqual(realm.objects(CPYFolder.self).count, 1)

        XCTAssertEqual(savedFolder?.index, folder.index)
        XCTAssertEqual(savedFolder?.title, folder.title)
        XCTAssertEqual(savedFolder?.enable, folder.enable)
    }

    func testRemoveFolder() throws {
        let folder = CPYFolder()
        let snippet = CPYSnippet()
        folder.snippets.append(snippet)
        let realm = try Realm()
        try realm.write {
            realm.add(folder)
        }

        XCTAssertEqual(realm.objects(CPYFolder.self).count, 1)
        XCTAssertEqual(realm.objects(CPYSnippet.self).count, 1)

        let copyFolder = folder.deepCopy()
        XCTAssertNil(copyFolder.realm)
        copyFolder.remove()

        XCTAssertEqual(realm.objects(CPYFolder.self).count, 0)
        XCTAssertEqual(realm.objects(CPYSnippet.self).count, 0)
    }

    // MARK: - Rearrange Index Tests

    func testRearrangeFolderIndex() throws {
        let folder = CPYFolder()
        folder.index = 100
        let folder2 = CPYFolder()
        folder2.index = 10

        let folders = [folder, folder2]
        let realm = try Realm()
        try realm.write {
            realm.add(folders)
        }

        let copyFolder = folder.deepCopy()
        let copyFolder2 = folder2.deepCopy()

        CPYFolder.rearrangesIndex([copyFolder, copyFolder2])

        XCTAssertEqual(copyFolder.index, 0)
        XCTAssertEqual(copyFolder2.index, 1)
        XCTAssertEqual(folder.index, 0)
        XCTAssertEqual(folder2.index, 1)
    }

    func testRearrangeSnippetIndex() throws {
        let folder = CPYFolder()
        let snippet = CPYSnippet()
        snippet.index = 10
        let snippet2 = CPYSnippet()
        snippet2.index = 100
        folder.snippets.append(snippet)
        folder.snippets.append(snippet2)
        let realm = try Realm()
        try realm.write {
            realm.add(folder)
        }

        let copyFolder = folder.deepCopy()
        copyFolder.rearrangesSnippetIndex()

        let copySnippet = try XCTUnwrap(copyFolder.snippets.first)
        let copySnippet2 = copyFolder.snippets[1]
        XCTAssertEqual(copySnippet.index, 0)
        XCTAssertEqual(copySnippet2.index, 1)
        XCTAssertEqual(snippet.index, 0)
        XCTAssertEqual(snippet2.index, 1)
    }
}
