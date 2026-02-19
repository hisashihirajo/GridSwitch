import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Dock非表示だがメニューバーアイコンは表示
app.setActivationPolicy(.accessory)

app.run()
