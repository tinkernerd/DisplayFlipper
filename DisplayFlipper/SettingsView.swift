import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(10)
                .shadow(radius: 2)

            Text("DisplayFlipper")
                .font(.title2)
                .bold()
            
            Text("Version 1.0")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) {
                    updateLaunchAtLogin()
                }
                .padding()

            Divider()
            
            Button(action: openGitHub) {
                HStack {
                    Image(systemName: "link")
                    Text("GitHub Repository")
                }
            }
            .buttonStyle(LinkButtonStyle())

            Spacer()
        }
        .frame(width: 300, height: 250)
        .padding()
    }

    func updateLaunchAtLogin() {
        let loginService = SMAppService.mainApp
        
        do {
            if launchAtLogin {
                try loginService.register()
                print("✅ App set to launch at login.")
            } else {
                try loginService.unregister()
                print("✅ App removed from login items.")
            }
        } catch {
            print("❌ Failed to update login item: \(error)")
        }
    }

    func openGitHub() {
        if let url = URL(string: "https://github.com/tinkernerd/DisplayFlipper") {
            NSWorkspace.shared.open(url)
        }
    }
}
