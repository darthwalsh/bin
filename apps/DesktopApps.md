I've been interested in cross-platform ways to code apps.
I'd like to have a small deployment footprint that doesn't involve shipping (multiple!) JS runtimes.
I have the most experience with HTML so I'd like to keep using that

[Tauri](https://tauri.app/): system webview, Rust main process
Edge WebView2: on Windows can share global installation, but macOS ships chromium
Electron: Chromium + NodeJS
Bun: has [tr1ckydev/webview-bun](https://github.com/tr1ckydev/webview-bun?tab=readme-ov-file#single-file-executable) can use [Single-file executable](https://bun.sh/docs/bundler/executables) allowing cross-compilatiom
QT: not sure what it ships
PySide: Python bindings for QT
Swing: Common in Java. Without styling looks very dated.
.NET MAUI
GTK, can support [windows](https://www.gtk.org/docs/installations/windows/) with MSYS2
- [ ] maybe let AI generate this summary
## Windows
WinForms
WPF
## macOS
Cocoa for OS X and iOS
SwiftUI