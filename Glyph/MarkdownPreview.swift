import SwiftUI
import WebKit

struct MarkdownPreview: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let body = MarkdownParser.toHTML(text)
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
        <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif;
            color: #e0e0e0;
            background: #000;
            padding: 16px;
            line-height: 1.6;
            font-size: 16px;
            -webkit-text-size-adjust: 100%;
        }
        h1 { font-size: 28px; margin: 20px 0 12px; color: #fff; }
        h2 { font-size: 24px; margin: 18px 0 10px; color: #fff; }
        h3 { font-size: 20px; margin: 16px 0 8px; color: #fff; }
        h4, h5, h6 { font-size: 17px; margin: 14px 0 6px; color: #fff; }
        p { margin: 0 0 12px; }
        code {
            font-family: 'SF Mono', Menlo, Consolas, monospace;
            background: #1a1a1a;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 14px;
        }
        pre {
            background: #1a1a1a;
            padding: 14px;
            border-radius: 8px;
            overflow-x: auto;
            margin: 0 0 12px;
        }
        pre code { padding: 0; background: none; }
        blockquote {
            border-left: 3px solid #444;
            padding-left: 14px;
            color: #999;
            margin: 0 0 12px;
        }
        ul, ol { padding-left: 24px; margin: 0 0 12px; }
        li { margin: 4px 0; }
        a { color: #58a6ff; text-decoration: none; }
        hr { border: 0; border-top: 1px solid #333; margin: 16px 0; }
        strong { color: #fff; }
        del { color: #888; }
        </style>
        </head>
        <body>\(body)</body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}
