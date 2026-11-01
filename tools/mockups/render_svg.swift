import AppKit
import Foundation
import WebKit

guard CommandLine.arguments.count == 4 else {
    fputs("Usage: render_svg input.svg output.png read-access-directory\n", stderr)
    exit(1)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1]).standardizedFileURL
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2]).standardizedFileURL
let readAccessURL = URL(fileURLWithPath: CommandLine.arguments[3]).standardizedFileURL
let application = NSApplication.shared
application.setActivationPolicy(.prohibited)

final class RenderDelegate: NSObject, WKNavigationDelegate {
    let webView: WKWebView
    let outputURL: URL

    init(webView: WKWebView, outputURL: URL) {
        self.webView = webView
        self.outputURL = outputURL
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let configuration = WKSnapshotConfiguration()
        configuration.rect = CGRect(x: 0, y: 0, width: 1280, height: 720)
        webView.takeSnapshot(with: configuration) { image, error in
            guard
                error == nil,
                let image,
                let tiffData = image.tiffRepresentation,
                let bitmap = NSBitmapImageRep(data: tiffData),
                let pngData = bitmap.representation(using: .png, properties: [:])
            else {
                fputs("Unable to render SVG.\n", stderr)
                exit(1)
            }

            do {
                try pngData.write(to: self.outputURL)
                exit(0)
            } catch {
                fputs("Unable to write PNG.\n", stderr)
                exit(1)
            }
        }
    }
}

let configuration = WKWebViewConfiguration()
let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 1280, height: 720), configuration: configuration)
let delegate = RenderDelegate(webView: webView, outputURL: outputURL)
webView.navigationDelegate = delegate
webView.loadFileURL(inputURL, allowingReadAccessTo: readAccessURL)
RunLoop.main.run()
