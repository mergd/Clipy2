//
//  NSPasteboard+Deprecated.swift
//
//  Clipy
//  GitHub: https://github.com/clipy
//  HP: https://clipy-app.com
//
//  Created by Econa77 on 2017/12/30.
//
//  Copyright © 2015-2018 Clipy Project.
//

import Cocoa

/**
 *  The contents of PasteboardType has been changed with swift 4.
 *  However, the archived Clipy history still stores these old names.
 *  Keep the deprecated constants isolated here while normalizing modern pasteboard types at the boundary.
 **/
extension NSPasteboard.PasteboardType {

    static var deprecatedString: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSStringPboardType")
    }

    static var deprecatedRTF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSRTFPboardType")
    }

    static var deprecatedRTFD: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSRTFDPboardType")
    }

    static var deprecatedPDF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSPDFPboardType")
    }

    static var deprecatedFilenames: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")
    }

    static var deprecatedURL: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSURLPboardType")
    }

    static var deprecatedTIFF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSTIFFPboardType")
    }

    static var modernPNG: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "public.png")
    }

    static var modernJPEG: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "public.jpeg")
    }

    static var modernTIFF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "public.tiff")
    }

    static var modernHEIC: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "public.heic")
    }

    static var modernImageTypes: [NSPasteboard.PasteboardType] {
        return [.modernPNG, .modernJPEG, .modernTIFF, .modernHEIC]
    }

    var clipyCompatibleType: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType.modernImageTypes.contains(self) ? .deprecatedTIFF : self
    }

}
