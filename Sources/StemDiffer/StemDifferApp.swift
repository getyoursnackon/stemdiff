import SwiftUI
import AppKit

@main
struct StemDifferApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            // Replace the default About menu
            CommandGroup(replacing: .appInfo) {
                Button("About StemDiffer") {
                    NSApplication.shared.orderFrontStandardAboutPanel()
                }
            }
        }
    }
} 