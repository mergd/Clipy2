import Cocoa
import XCTest
@testable import Clipy2

final class ClipDataTests: XCTestCase {

    func testModernImagePasteboardTypesNormalizeToDeprecatedTIFF() {
        XCTAssertEqual(NSPasteboard.PasteboardType.modernPNG.clipyCompatibleType, .deprecatedTIFF)
        XCTAssertEqual(NSPasteboard.PasteboardType.modernJPEG.clipyCompatibleType, .deprecatedTIFF)
        XCTAssertEqual(NSPasteboard.PasteboardType.modernTIFF.clipyCompatibleType, .deprecatedTIFF)
        XCTAssertEqual(NSPasteboard.PasteboardType.modernHEIC.clipyCompatibleType, .deprecatedTIFF)
        XCTAssertEqual(NSPasteboard.PasteboardType.deprecatedString.clipyCompatibleType, .deprecatedString)
    }

    func testImageHashIncludesDimensions() {
        let first = CPYClipData(image: image(width: 10, height: 20))
        let second = CPYClipData(image: image(width: 20, height: 10))

        XCTAssertNotEqual(first.hash, second.hash)
    }

    private func image(width: CGFloat, height: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: width, height: height))
        image.lockFocus()
        NSColor.black.setFill()
        NSRect(x: 0, y: 0, width: width, height: height).fill()
        image.unlockFocus()
        return image
    }
}
