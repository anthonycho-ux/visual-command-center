import AppKit
import Foundation

struct FeedMessage: Decodable {
    let time: String
    let source: String
    let text: String
}

final class FeedReader {
    private let path: URL

    init() {
        path = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".gjc")
            .appendingPathComponent("visual-feed")
            .appendingPathComponent("messages.jsonl")
    }

    func latestMessage() -> FeedMessage? {
        guard let data = try? Data(contentsOf: path),
              let body = String(data: data, encoding: .utf8) else {
            return nil
        }

        for line in body.split(separator: "\n").reversed() {
            guard let lineData = String(line).data(using: .utf8),
                  let message = try? JSONDecoder().decode(FeedMessage.self, from: lineData) else {
                continue
            }
            return message
        }

        return nil
    }
}

final class CommandCenterWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    init() {
        let screenFrame = NSScreen.screens
            .map(\.visibleFrame)
            .max { left, right in
                left.width * left.height < right.width * right.height
            } ?? NSRect(x: 80, y: 80, width: 1200, height: 800)
        let size = NSSize(width: 460, height: 280)
        let origin = NSPoint(
            x: screenFrame.minX + 40,
            y: screenFrame.minY + 40
        )

        super.init(
            contentRect: NSRect(origin: origin, size: size),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        title = "Visual Command Center"
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        isFloatingPanel = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .moveToActiveSpace, .transient]
        backgroundColor = .clear
        minSize = NSSize(width: 360, height: 220)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let reader = FeedReader()
    private var window: CommandCenterWindow!
    private let sourceLabel = NSTextField(labelWithString: "GJC")
    private let timeLabel = NSTextField(labelWithString: "")
    private let messageLabel = NSTextField(wrappingLabelWithString: "Waiting for the first visual response.")
    private var timer: Timer?
    private var lastText = ""

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        buildWindow()
        updateMessage()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateMessage()
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func buildWindow() {
        window = CommandCenterWindow()

        let background = NSVisualEffectView()
        background.material = .hudWindow
        background.blendingMode = .behindWindow
        background.state = .active
        background.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = NSTextField(labelWithString: "Visual Command Center")
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white

        sourceLabel.font = .monospacedSystemFont(ofSize: 12, weight: .semibold)
        sourceLabel.textColor = NSColor(calibratedRed: 0.55, green: 0.42, blue: 1.0, alpha: 1.0)
        timeLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        timeLabel.textColor = .secondaryLabelColor

        messageLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        messageLabel.textColor = .white
        messageLabel.maximumNumberOfLines = 6
        messageLabel.lineBreakMode = .byWordWrapping

        let openButton = NSButton(title: "Open feed", target: self, action: #selector(openFeedFolder))
        openButton.bezelStyle = .rounded

        let refreshButton = NSButton(title: "Refresh", target: self, action: #selector(refreshNow))
        refreshButton.bezelStyle = .rounded

        let header = NSStackView(views: [titleLabel, NSView(), sourceLabel, timeLabel])
        header.orientation = .horizontal
        header.alignment = .centerY
        header.spacing = 10

        let controls = NSStackView(views: [openButton, refreshButton, NSView()])
        controls.orientation = .horizontal
        controls.alignment = .leading
        controls.spacing = 10

        let stack = NSStackView(views: [header, messageLabel, controls])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false

        let root = NSView()
        root.addSubview(background)
        root.addSubview(stack)
        window.contentView = root

        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            background.topAnchor.constraint(equalTo: root.topAnchor),
            background.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: root.topAnchor, constant: 22),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: root.bottomAnchor, constant: -18),
            messageLabel.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])

        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func openFeedFolder() {
        let directory = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".gjc")
            .appendingPathComponent("visual-feed")
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        NSWorkspace.shared.open(directory)
    }

    @objc private func refreshNow() {
        updateMessage()
    }

    private func updateMessage() {
        guard let message = reader.latestMessage() else {
            messageLabel.stringValue = "Waiting for the first visual response."
            sourceLabel.stringValue = "GJC"
            timeLabel.stringValue = ""
            return
        }

        if message.text == lastText {
            return
        }

        lastText = message.text
        sourceLabel.stringValue = message.source.uppercased()
        timeLabel.stringValue = message.time
        messageLabel.stringValue = message.text
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
withExtendedLifetime(delegate) {
    app.run()
}
