import AppKit
import Foundation

struct Usage: Decodable {
    let fiveRemaining: Double?
    let fiveReset: Double?
    let weeklyRemaining: Double?
    let weeklyReset: Double?
    let error: String?
}

final class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    var timer: Timer?

    let fiveItem = NSMenuItem(
        title: "5-hour limit",
        action: nil,
        keyEquivalent: ""
    )

    let fiveResetItem = NSMenuItem(
        title: "",
        action: nil,
        keyEquivalent: ""
    )

    let weekItem = NSMenuItem(
        title: "Weekly limit",
        action: nil,
        keyEquivalent: ""
    )

    let weekResetItem = NSMenuItem(
        title: "",
        action: nil,
        keyEquivalent: ""
    )

    let updatedItem = NSMenuItem(
        title: "",
        action: nil,
        keyEquivalent: ""
    )

    func applicationDidFinishLaunching(_ notification: Notification) {

        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        if let button = statusItem.button {

            let iconPath =
                "/Applications/ChatGPT.app/Contents/Resources/chatgptTemplate@2x.png"

            if let icon = NSImage(contentsOfFile: iconPath) {
                icon.size = NSSize(width: 16, height: 16)
                icon.isTemplate = true

                button.image = icon
                button.imagePosition = .imageLeading
                button.imageScaling = .scaleProportionallyDown
            } else {
                button.image = NSImage(
                    systemSymbolName: "gauge.with.dots.needle.33percent",
                    accessibilityDescription: "Codex Usage"
                )
                button.imagePosition = .imageLeading
            }

            button.title = " …"
        }

        let menu = NSMenu()

        menu.addItem(fiveItem)
        menu.addItem(fiveResetItem)

        menu.addItem(.separator())

        menu.addItem(weekItem)
        menu.addItem(weekResetItem)

        menu.addItem(.separator())

        menu.addItem(updatedItem)

        menu.addItem(.separator())

        let refresh = NSMenuItem(
            title: "Refresh now",
            action: #selector(refreshNow),
            keyEquivalent: "r"
        )
        refresh.target = self
        menu.addItem(refresh)

        let usage = NSMenuItem(
            title: "Open Usage Dashboard",
            action: #selector(openUsage),
            keyEquivalent: ""
        )
        usage.target = self
        menu.addItem(usage)

        menu.addItem(.separator())

        let quit = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quit.target = self
        menu.addItem(quit)

        statusItem.menu = menu

        refreshUsage()

        timer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: true
        ) { [weak self] _ in
            self?.refreshUsage()
        }
    }

    @objc func refreshNow() {
        refreshUsage()
    }

    func refreshUsage() {

        DispatchQueue.global(qos: .utility).async {

            let task = Process()
            let pipe = Pipe()

            task.executableURL = URL(fileURLWithPath: "/bin/zsh")

            task.arguments = [
                "-lc",
                "python3 \"$HOME/.codex-usage-menu/usage.py\""
            ]

            task.standardOutput = pipe

            do {
                try task.run()
                task.waitUntilExit()

                let data =
                    pipe.fileHandleForReading.readDataToEndOfFile()

                let usage =
                    try JSONDecoder().decode(Usage.self, from: data)

                DispatchQueue.main.async {
                    self.updateUI(usage)
                }

            } catch {

                DispatchQueue.main.async {
                    self.statusItem.button?.title = " ⚠︎"
                    self.updatedItem.title = "Refresh failed"
                }
            }
        }
    }

    func updateUI(_ usage: Usage) {

        if let error = usage.error {
            statusItem.button?.title = " ⚠︎"
            updatedItem.title = error
            return
        }

        let five =
            usage.fiveRemaining.map { Int($0.rounded()) }

        let week =
            usage.weeklyRemaining.map { Int($0.rounded()) }

        let fiveText =
            five.map { "\($0)%" } ?? "--"

        let weekText =
            week.map { "\($0)%" } ?? "--"

        let lowest =
            min(five ?? 100, week ?? 100)

        let warning: String

        if lowest <= 10 {
            warning = "🔴 "
        } else if lowest <= 20 {
            warning = "⚠︎ "
        } else {
            warning = ""
        }

        statusItem.button?.title =
            " \(warning)5h \(fiveText) · W \(weekText)"

        fiveItem.title =
            "5-hour limit    \(fiveText) remaining"

        fiveResetItem.title =
            resetText(usage.fiveReset)

        weekItem.title =
            "Weekly limit   \(weekText) remaining"

        weekResetItem.title =
            resetText(usage.weeklyReset)

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"

        updatedItem.title =
            "Last updated \(formatter.string(from: Date()))"
    }

    func resetText(_ timestamp: Double?) -> String {

        guard let timestamp else {
            return "Reset time unavailable"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"

        let resetDate = Date(timeIntervalSince1970: timestamp)
        return "↻ Resets \(formatter.string(from: resetDate))"
    }

    @objc func openUsage() {

        if let url = URL(
            string: "https://chatgpt.com/codex/settings/usage"
        ) {
            NSWorkspace.shared.open(url)
        }
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()

app.delegate = delegate
app.run()
