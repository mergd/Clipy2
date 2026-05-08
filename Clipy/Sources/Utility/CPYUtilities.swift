//
//  CPYUtilities.swift
//
//  Clipy
//  GitHub: https://github.com/clipy
//  HP: https://clipy-app.com
//
//  Created by Econa77 on 2015/06/21.
//
//  Copyright © 2015-2018 Clipy Project.
//

import Cocoa
import RealmSwift
import KeyHolder
import OSLog

final class CPYUtilities {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.clipy2.app",
        category: "Diagnostics"
    )

    static func initSDKs() {
        AppEnvironment.current.defaults.register(defaults: ["NSApplicationCrashOnExceptions": true])
        guard AppEnvironment.current.defaults.bool(forKey: Constants.UserDefaults.collectCrashReport) else { return }
        CPYUtilities.sendCustomLog(with: "applicationDidFinishLaunching")
    }

    static func registerUserDefaultKeys() {
        var defaultValues = [String: Any]()

        defaultValues.updateValue(HotKeyService.defaultKeyCombos, forKey: Constants.UserDefaults.hotKeys)
        /* General */
        defaultValues.updateValue(NSNumber(value: false), forKey: Constants.UserDefaults.loginItem)
        defaultValues.updateValue(NSNumber(value: false), forKey: Constants.UserDefaults.suppressAlertForLoginItem)
        defaultValues.updateValue(NSNumber(value: 30), forKey: Constants.UserDefaults.maxHistorySize)
        defaultValues.updateValue(NSNumber(value: 1), forKey: Constants.UserDefaults.showStatusItem)
        defaultValues.updateValue(AppDelegate.storeTypesDictinary(), forKey: Constants.UserDefaults.storeTypes)
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.UserDefaults.inputPasteCommand)
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.UserDefaults.reorderClipsAfterPasting)
        defaultValues.updateValue(NSNumber(value: false), forKey: Constants.UserDefaults.collectCrashReport)

        /* Menu */
        defaultValues.updateValue(NSNumber(value: 16), forKey: Constants.UserDefaults.menuIconSize)
        defaultValues.updateValue(NSNumber(value: 20), forKey: Constants.UserDefaults.maxMenuItemTitleLength)
        defaultValues.updateValue(NSNumber(value: 0), forKey: Constants.UserDefaults.numberOfItemsPlaceInline)
        defaultValues.updateValue(NSNumber(value: 10), forKey: Constants.UserDefaults.numberOfItemsPlaceInsideFolder)
        defaultValues.updateValue(NSNumber(value: false), forKey: Constants.UserDefaults.menuItemsTitleStartWithZero)
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.UserDefaults.showAlertBeforeClearHistory)
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.UserDefaults.addClearHistoryMenuItem)
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.UserDefaults.showIconInTheMenu)
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.UserDefaults.menuItemsAreMarkedWithNumbers)
        defaultValues.updateValue(NSNumber(value: false), forKey: Constants.UserDefaults.addNumericKeyEquivalents)
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.UserDefaults.showToolTipOnMenuItem)
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.UserDefaults.showImageInTheMenu)
        defaultValues.updateValue(NSNumber(value: 200), forKey: Constants.UserDefaults.maxLengthOfToolTip)
        defaultValues.updateValue(NSNumber(value: 100), forKey: Constants.UserDefaults.thumbnailWidth)
        defaultValues.updateValue(NSNumber(value: 32), forKey: Constants.UserDefaults.thumbnailHeight)
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.UserDefaults.overwriteSameHistory)
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.UserDefaults.copySameHistory)
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.UserDefaults.showColorPreviewInTheMenu)

        /* Updates */
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.Update.enableAutomaticCheck)
        defaultValues.updateValue(NSNumber(value: 86400), forKey: Constants.Update.checkInterval)

        /* Beta */
        defaultValues.updateValue(NSNumber(value: true), forKey: Constants.Beta.pastePlainText)
        defaultValues.updateValue(NSNumber(value: 0), forKey: Constants.Beta.pastePlainTextModifier)
        defaultValues.updateValue(NSNumber(value: false), forKey: Constants.Beta.deleteHistory)
        defaultValues.updateValue(NSNumber(value: 0), forKey: Constants.Beta.deleteHistoryModifier)
        defaultValues.updateValue(NSNumber(value: false), forKey: Constants.Beta.pasteAndDeleteHistory)
        defaultValues.updateValue(NSNumber(value: 0), forKey: Constants.Beta.pasteAndDeleteHistoryModifier)
        defaultValues.updateValue(NSNumber(value: false), forKey: Constants.Beta.observerScreenshot)

        AppEnvironment.current.defaults.register(defaults: defaultValues)
        AppEnvironment.current.defaults.synchronize()
    }

    static func applicationSupportFolder() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let basePath: String = paths.first ?? NSTemporaryDirectory()
        return (basePath as NSString).appendingPathComponent(Constants.Application.name)
    }

    static func prepareSaveToPath(_ path: String) -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        if (fileManager.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue) == false {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return false
            }
        }
        return true
    }

    static func deleteData(at path: String) {
        autoreleasepool {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path) {
                try? fileManager.removeItem(atPath: path)
            }
        }
    }

    static func sendCustomLog(with name: String) {
        guard AppEnvironment.current.defaults.bool(forKey: Constants.UserDefaults.collectCrashReport) else { return }
        logger.info("\(name, privacy: .public)")
    }
}

enum CPYNativeControlStyler {
    static func styleControls(in view: NSView?) {
        guard let view = view else { return }
        view.wantsLayer = true

        switch view {
        case let scrollView as NSScrollView:
            scrollView.drawsBackground = true
            scrollView.backgroundColor = .controlBackgroundColor
            scrollView.contentView.drawsBackground = true
            scrollView.contentView.backgroundColor = .controlBackgroundColor
        case let textView as NSTextView:
            textView.font = textView.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            textView.textColor = .textColor
            textView.backgroundColor = .textBackgroundColor
            textView.insertionPointColor = .textColor
            if let placeholderTextView = textView as? CPYPlaceHolderTextView {
                placeholderTextView.placeHolderColor = .placeholderTextColor
            }
        case let tableView as NSTableView:
            tableView.backgroundColor = .controlBackgroundColor
            tableView.gridColor = .separatorColor
        case let recordView as RecordView:
            styleRecordView(recordView)
        default:
            view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        }

        for subview in view.subviews {
            switch subview {
            case let textField as NSTextField:
                styleTextField(textField)
            case let popup as NSPopUpButton:
                popup.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
                styleButton(popup)
            case let button as NSButton:
                styleButton(button)
            case let box as NSBox:
                box.isTransparent = true
                box.titleFont = NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)
            default:
                break
            }

            styleControls(in: subview)
        }
    }

    private static func styleTextField(_ textField: NSTextField) {
        textField.font = textField.font.map { NSFont.systemFont(ofSize: $0.pointSize) }
        textField.textColor = textField.isEditable ? .textColor : .labelColor
        textField.backgroundColor = textField.isEditable ? .textBackgroundColor : .clear

        guard !textField.isEditable else { return }
        if let title = textField.stringValue.nilIfEmpty {
            textField.attributedStringValue = NSAttributedString(
                string: title,
                attributes: [.foregroundColor: NSColor.labelColor, .font: textField.font as Any]
            )
        }
    }

    private static func styleButton(_ button: NSButton) {
        button.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        if button.bezelStyle == .rounded || button.bezelStyle == .regularSquare {
            button.controlSize = .regular
        }
    }

    private static func styleRecordView(_ recordView: RecordView) {
        recordView.backgroundColor = .controlBackgroundColor
        recordView.borderColor = .separatorColor
        recordView.borderWidth = 1
        recordView.cornerRadius = 8
        recordView.tintColor = .controlAccentColor
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
