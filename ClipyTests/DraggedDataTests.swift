import XCTest
@testable import Clipy

final class DraggedDataTests: XCTestCase {

    func testArchiveData() throws {
        let draggedData = CPYDraggedData(
            type: .folder,
            folderIdentifier: NSUUID().uuidString,
            snippetIdentifier: nil,
            index: 10
        )

        let data = NSKeyedArchiver.archivedData(withRootObject: draggedData)
        let unarchiveData = try XCTUnwrap(NSKeyedUnarchiver.unarchiveObject(with: data) as? CPYDraggedData)

        XCTAssertEqual(unarchiveData.type, draggedData.type)
        XCTAssertEqual(unarchiveData.folderIdentifier, draggedData.folderIdentifier)
        XCTAssertNil(unarchiveData.snippetIdentifier)
        XCTAssertEqual(unarchiveData.index, draggedData.index)
    }
}
