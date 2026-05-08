//
//  CPYPreferencesWindowController.swift
//
//  Clipy
//  GitHub: https://github.com/clipy
//  HP: https://clipy-app.com
//
//  Created by Econa77 on 2016/02/25.
//
//  Copyright © 2015-2018 Clipy Project.
//

import Cocoa

final class CPYPreferencesWindowController: NSWindowController {

    // MARK: - Properties
    static let sharedController = CPYPreferencesWindowController(windowNibName: "CPYPreferencesWindowController")

    private enum Pane: Int, CaseIterable {
        case general
        case menu
        case type
        case exclude
        case shortcuts
        case updates

        var toolbarIdentifier: NSToolbarItem.Identifier {
            return NSToolbarItem.Identifier("com.clipy2.preferences.\(rawValue)")
        }

        var title: String {
            switch self {
            case .general: return "General"
            case .menu: return "Menu"
            case .type: return "Types"
            case .exclude: return "Exclude"
            case .shortcuts: return "Shortcuts"
            case .updates: return "Updates"
            }
        }

        var symbolName: String {
            switch self {
            case .general: return "gearshape"
            case .menu: return "list.bullet.rectangle"
            case .type: return "doc.on.clipboard"
            case .exclude: return "minus.circle"
            case .shortcuts: return "keyboard"
            case .updates: return "arrow.triangle.2.circlepath"
            }
        }
    }

    private let toolbarIdentifier = NSToolbar.Identifier("com.clipy2.preferences.toolbar")
    @IBOutlet private weak var toolBar: NSView!
    // ImageViews
    @IBOutlet private weak var generalImageView: NSImageView!
    @IBOutlet private weak var menuImageView: NSImageView!
    @IBOutlet private weak var typeImageView: NSImageView!
    @IBOutlet private weak var excludeImageView: NSImageView!
    @IBOutlet private weak var shortcutsImageView: NSImageView!
    @IBOutlet private weak var updatesImageView: NSImageView!
    // Labels
    @IBOutlet private weak var generalTextField: NSTextField!
    @IBOutlet private weak var menuTextField: NSTextField!
    @IBOutlet private weak var typeTextField: NSTextField!
    @IBOutlet private weak var excludeTextField: NSTextField!
    @IBOutlet private weak var shortcutsTextField: NSTextField!
    @IBOutlet private weak var updatesTextField: NSTextField!
    // Buttons
    @IBOutlet private weak var generalButton: NSButton!
    @IBOutlet private weak var menuButton: NSButton!
    @IBOutlet private weak var typeButton: NSButton!
    @IBOutlet private weak var excludeButton: NSButton!
    @IBOutlet private weak var shortcutsButton: NSButton!
    @IBOutlet private weak var updatesButton: NSButton!
    // ViewController
    private let viewController = [NSViewController(nibName: "CPYGeneralPreferenceViewController", bundle: nil),
                                  NSViewController(nibName: "CPYMenuPreferenceViewController", bundle: nil),
                                  CPYTypePreferenceViewController(nibName: "CPYTypePreferenceViewController", bundle: nil),
                                  CPYExcludeAppPreferenceViewController(nibName: "CPYExcludeAppPreferenceViewController", bundle: nil),
                                  CPYShortcutsPreferenceViewController(nibName: "CPYShortcutsPreferenceViewController", bundle: nil),
                                  CPYUpdatesPreferenceViewController(nibName: "CPYUpdatesPreferenceViewController", bundle: nil)]

    // MARK: - Window Life Cycle
    override func windowDidLoad() {
        super.windowDidLoad()
        configureWindow()
        configureNativeToolbar()
        toolBarItemTapped(generalButton)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(self)
    }
}

// MARK: - IBActions
extension CPYPreferencesWindowController {
    @IBAction private func toolBarItemTapped(_ sender: NSButton) {
        selectedTab(sender.tag)
        switchView(sender.tag)
    }

    @objc private func nativeToolbarItemTapped(_ sender: NSToolbarItem) {
        guard let pane = Pane.allCases.first(where: { $0.toolbarIdentifier == sender.itemIdentifier }) else { return }
        window?.toolbar?.selectedItemIdentifier = pane.toolbarIdentifier
        selectedTab(pane.rawValue)
        switchView(pane.rawValue)
    }
}

// MARK: - NSWindow Delegate
extension CPYPreferencesWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let viewController = viewController[2] as? CPYTypePreferenceViewController {
            AppEnvironment.current.defaults.set(viewController.storeTypes, forKey: Constants.UserDefaults.storeTypes)
            AppEnvironment.current.defaults.synchronize()
        }
        if let window = window, !window.makeFirstResponder(window) {
            window.endEditing(for: nil)
        }
        NSApp.deactivate()
    }
}

// MARK: - Layout
private extension CPYPreferencesWindowController {
    func configureWindow() {
        guard let window = window else { return }
        window.title = "\(Constants.Application.name) Settings"
        window.collectionBehavior = .canJoinAllSpaces
        window.backgroundColor = .windowBackgroundColor
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = true
        window.minSize = NSSize(width: 520, height: 340)
        toolBar.removeFromSuperview()
    }

    func configureNativeToolbar() {
        let toolbar = NSToolbar(identifier: toolbarIdentifier)
        toolbar.delegate = self
        toolbar.displayMode = .iconAndLabel
        toolbar.sizeMode = .regular
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = false
        toolbar.selectedItemIdentifier = Pane.general.toolbarIdentifier
        window?.toolbar = toolbar
    }

    func resetImages() {
        generalImageView.image = Asset.prefGeneral.image
        menuImageView.image = Asset.prefMenu.image
        typeImageView.image = Asset.prefType.image
        excludeImageView.image = Asset.prefExcluded.image
        shortcutsImageView.image = Asset.prefShortcut.image
        updatesImageView.image = Asset.prefUpdate.image

        generalTextField.textColor = ColorName.tabTitle.color
        menuTextField.textColor = ColorName.tabTitle.color
        typeTextField.textColor = ColorName.tabTitle.color
        excludeTextField.textColor = ColorName.tabTitle.color
        shortcutsTextField.textColor = ColorName.tabTitle.color
        updatesTextField.textColor = ColorName.tabTitle.color
    }

    func selectedTab(_ index: Int) {
        resetImages()
        if let pane = Pane(rawValue: index) {
            window?.toolbar?.selectedItemIdentifier = pane.toolbarIdentifier
            window?.title = "\(Constants.Application.name) \(pane.title)"
        }

        switch index {
        case 0:
            generalImageView.image = Asset.prefGeneralOn.image
            generalTextField.textColor = ColorName.clipy.color
        case 1:
            menuImageView.image = Asset.prefMenuOn.image
            menuTextField.textColor = ColorName.clipy.color
        case 2:
            typeImageView.image = Asset.prefTypeOn.image
            typeTextField.textColor = ColorName.clipy.color
        case 3:
            excludeImageView.image = Asset.prefExcludedOn.image
            excludeTextField.textColor = ColorName.clipy.color
        case 4:
            shortcutsImageView.image = Asset.prefShortcutOn.image
            shortcutsTextField.textColor = ColorName.clipy.color
        case 5:
            updatesImageView.image = Asset.prefUpdateOn.image
            updatesTextField.textColor = ColorName.clipy.color
        default: break
        }
    }

    func switchView(_ index: Int) {
        let newView = viewController[index].view
        preparePanel(newView)
        // Remove current views without toolbar
        window?.contentView?.subviews.forEach { view in
            if view != toolBar {
                view.removeFromSuperview()
            }
        }
        // Resize view
        let frame = window!.frame
        var newFrame = window!.frameRect(forContentRect: newView.frame)
        newFrame.origin = frame.origin
        newFrame.origin.y += frame.height - newFrame.height
        window?.setFrame(newFrame, display: true)
        window?.contentView?.addSubview(newView)
    }

    func preparePanel(_ view: NSView) {
        view.autoresizingMask = [.width, .height]
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        styleControls(in: view)
    }

    func styleControls(in view: NSView) {
        for subview in view.subviews {
            if let textField = subview as? NSTextField {
                textField.font = textField.font.map { NSFont.systemFont(ofSize: $0.pointSize) }
                if !textField.isEditable {
                    textField.textColor = .labelColor
                    textField.backgroundColor = .clear
                }
            } else if let button = subview as? NSButton {
                button.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
                if button.bezelStyle == .rounded || button.bezelStyle == .regularSquare {
                    button.controlSize = .regular
                }
            } else if let box = subview as? NSBox {
                box.isTransparent = true
                box.titleFont = NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)
            }
            styleControls(in: subview)
        }
    }
}

// MARK: - NSToolbarDelegate
extension CPYPreferencesWindowController: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return Pane.allCases.map { $0.toolbarIdentifier }
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return Pane.allCases.map { $0.toolbarIdentifier }
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return Pane.allCases.map { $0.toolbarIdentifier }
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        guard let pane = Pane.allCases.first(where: { $0.toolbarIdentifier == itemIdentifier }) else { return nil }

        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = pane.title
        item.paletteLabel = pane.title
        item.toolTip = pane.title
        item.target = self
        item.action = #selector(nativeToolbarItemTapped(_:))

        if let image = NSImage(systemSymbolName: pane.symbolName, accessibilityDescription: pane.title) {
            item.image = image
        }

        return item
    }
}
