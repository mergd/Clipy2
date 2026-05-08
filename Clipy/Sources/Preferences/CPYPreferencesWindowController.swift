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
        selectPane(.general)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(self)
    }
}

// MARK: - IBActions
extension CPYPreferencesWindowController {
    @objc private func nativeToolbarItemTapped(_ sender: NSToolbarItem) {
        guard let pane = Pane.allCases.first(where: { $0.toolbarIdentifier == sender.itemIdentifier }) else { return }
        selectPane(pane)
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
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = true
        window.minSize = NSSize(width: 520, height: 340)
    }

    func configureNativeToolbar() {
        let toolbar = NSToolbar(identifier: toolbarIdentifier)
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.sizeMode = .regular
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = false
        toolbar.selectedItemIdentifier = Pane.general.toolbarIdentifier
        window?.toolbar = toolbar
    }

    private func selectPane(_ pane: Pane) {
        window?.toolbar?.selectedItemIdentifier = pane.toolbarIdentifier
        window?.title = "\(Constants.Application.name) \(pane.title)"
        switchView(pane.rawValue)
    }

    func switchView(_ index: Int) {
        let newView = viewController[index].view
        preparePanel(newView)
        window?.contentView?.subviews.forEach { view in
            view.removeFromSuperview()
        }
        // Resize view
        let frame = window!.frame
        var newFrame = window!.frameRect(forContentRect: newView.frame)
        newFrame.size.width = max(newFrame.width, window!.minSize.width)
        newFrame.origin = frame.origin
        newFrame.origin.y += frame.height - newFrame.height
        window?.setFrame(newFrame, display: true)
        newView.frame.origin = .zero
        newView.frame.size.width = window?.contentView?.bounds.width ?? newView.frame.width
        window?.contentView?.addSubview(newView)
    }

    func preparePanel(_ view: NSView) {
        view.autoresizingMask = [.width, .height]
        CPYNativeControlStyler.styleControls(in: view)
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
