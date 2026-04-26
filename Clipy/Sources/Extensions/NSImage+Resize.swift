//
//  NSImage+Resize.swift
//
//  Clipy
//  GitHub: https://github.com/clipy
//  HP: https://clipy-app.com
//
//  Created by Econa77 on 2015/07/26.
//
//  Copyright © 2015-2018 Clipy Project.
//

import Foundation
import Cocoa

extension NSImage {
    var pixelSizeHash: Int {
        guard let representation = representations.first else {
            return Int(size.width.rounded()) &* 31 ^ Int(size.height.rounded())
        }

        return representation.pixelsWide &* 31 ^ representation.pixelsHigh
    }

    func resizeImage(_ width: CGFloat, _ height: CGFloat) -> NSImage? {

        let representations = self.representations
        var bitmapRep: NSBitmapImageRep?

        for rep in representations {
            if let rep = rep as? NSBitmapImageRep {
                bitmapRep = rep
                break
            }
        }

        let origWidth: CGFloat
        let origHeight: CGFloat

        if let bitmapRep = bitmapRep {
            origWidth = CGFloat(bitmapRep.pixelsWide)
            origHeight = CGFloat(bitmapRep.pixelsHigh)
        } else if size.width > 0 && size.height > 0 {
            origWidth = size.width
            origHeight = size.height
        } else {
            return nil
        }

        let aspect = CGFloat(origWidth) / CGFloat(origHeight)

        let targetWidth = width
        let targetHeight = height
        var newWidth: CGFloat
        var newHeight: CGFloat

        if aspect >= 1 {
            newWidth = targetWidth
            newHeight = newWidth / aspect

            if targetHeight < newHeight {
                newHeight = targetHeight
                newWidth = targetHeight * aspect
            }
        } else {
            newHeight = targetHeight
            newWidth = targetHeight * aspect

            if targetWidth < newWidth {
                newWidth = targetWidth
                newHeight = targetWidth / aspect
            }
        }

        if origWidth < newWidth {
            newWidth = origWidth
        }
        if origHeight < newHeight {
            newHeight = origHeight
        }

        if let newImageRep = bestRepresentation(for: NSRect(x: 0, y: 0, width: newWidth, height: newHeight), context: nil, hints: nil) {
            let thumbnail = NSImage(size: NSSize(width: newWidth, height: newHeight))
            thumbnail.addRepresentation(newImageRep)
            return thumbnail
        }

        let thumbnail = NSImage(size: NSSize(width: newWidth, height: newHeight))
        thumbnail.lockFocus()
        draw(in: NSRect(x: 0, y: 0, width: newWidth, height: newHeight),
             from: NSRect(origin: .zero, size: size),
             operation: .copy,
             fraction: 1.0)
        thumbnail.unlockFocus()
        return thumbnail
    }
}
