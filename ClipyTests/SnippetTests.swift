import XCTest
import RealmSwift
@testable import Clipy2

final class SnippetTests: XCTestCase {

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

    func testMergeSnippet() throws {
        let snippet = CPYSnippet()
        let realm = try Realm()
        try realm.write {
            realm.add(snippet)
        }

        let snippet2 = CPYSnippet()
        snippet2.identifier = snippet.identifier
        snippet2.index = 100
        snippet2.title = "title"
        snippet2.content = "content"
        snippet2.merge()

        XCTAssertNil(snippet2.realm)
        XCTAssertEqual(snippet.index, snippet2.index)
        XCTAssertEqual(snippet.title, snippet2.title)
        XCTAssertEqual(snippet.content, snippet2.content)
    }

    func testRemoveSnippet() throws {
        let realm = try Realm()
        XCTAssertEqual(realm.objects(CPYSnippet.self).count, 0)

        let snippet = CPYSnippet()
        try realm.write {
            realm.add(snippet)
        }

        XCTAssertEqual(realm.objects(CPYSnippet.self).count, 1)

        let snippet2 = CPYSnippet()
        snippet2.identifier = snippet.identifier
        snippet2.remove()

        XCTAssertEqual(realm.objects(CPYSnippet.self).count, 0)
    }
}
