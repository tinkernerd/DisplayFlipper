//
//  DisplayFlipperApp.swift
//  DisplayFlipper
//
//  Created by Nick Stull on 3/15/25.
//

import SwiftUI
import ServiceManagement

@main
struct DisplayRotatorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        hideDockIcon()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "display", accessibilityDescription: "Toggle Display")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Vertical", action: #selector(setVertical), keyEquivalent: "v"))
        menu.addItem(NSMenuItem(title: "Horizontal", action: #selector(setHorizontal), keyEquivalent: "h"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: "s"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func setHorizontal() {
        runShellScript("~/ToggHorz.sh")
    }

    @objc func setVertical() {
        runShellScript("~/ToggVert.sh")
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func runShellScript(_ scriptPath: String) {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", scriptPath]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe

        do {
            try process.run()
        } catch {
            print("Failed to execute script: \(error)")
            return
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = String(data: outputData, encoding: .utf8) ?? "No output"

        print("Script Output: \(outputString)")

        process.waitUntilExit()
    }

    @objc func openSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil) // Bring existing window to front
            NSApp.activate(ignoringOtherApps: true) // Ensure it pops on top
        } else {
            let settingsView = NSHostingView(rootView: SettingsView())
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.title = "Settings"
            window.contentView = settingsView
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true) // Ensure it opens above everything
            settingsWindow = window
        }
    }

    func hideDockIcon() {
        NSApp.setActivationPolicy(.accessory)
    }
}
