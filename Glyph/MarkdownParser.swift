import Foundation

enum MarkdownParser {

    static func toHTML(_ markdown: String) -> String {
        let lines = markdown.components(separatedBy: "\n")
        var html = ""
        var inCodeBlock = false
        var inList = false
        var listTag = ""

        for line in lines {
            // --- fenced code blocks ---
            if line.hasPrefix("```") {
                if inCodeBlock {
                    html += "</code></pre>\n"
                    inCodeBlock = false
                } else {
                    closeList(&html, &inList, &listTag)
                    html += "<pre><code>"
                    inCodeBlock = true
                }
                continue
            }
            if inCodeBlock {
                html += escapeHTML(line) + "\n"
                continue
            }

            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // --- blank line ---
            if trimmed.isEmpty {
                closeList(&html, &inList, &listTag)
                continue
            }

            // --- headings ---
            if let level = headingLevel(trimmed) {
                closeList(&html, &inList, &listTag)
                let content = String(trimmed.dropFirst(level).drop(while: { $0 == " " }))
                html += "<h\(level)>\(inline(content))</h\(level)>\n"
                continue
            }

            // --- horizontal rule ---
            if trimmed.range(of: #"^(---+|\*\*\*+|___+)\s*$"#, options: .regularExpression) != nil {
                closeList(&html, &inList, &listTag)
                html += "<hr>\n"
                continue
            }

            // --- blockquote ---
            if trimmed.hasPrefix("> ") {
                closeList(&html, &inList, &listTag)
                let content = String(trimmed.dropFirst(2))
                html += "<blockquote><p>\(inline(content))</p></blockquote>\n"
                continue
            }

            // --- unordered list ---
            if trimmed.range(of: #"^[\*\-\+]\s+"#, options: .regularExpression) != nil {
                if !inList || listTag != "ul" {
                    closeList(&html, &inList, &listTag)
                    html += "<ul>\n"
                    inList = true
                    listTag = "ul"
                }
                let content = trimmed.replacingOccurrences(
                    of: #"^[\*\-\+]\s+"#, with: "", options: .regularExpression)
                html += "<li>\(inline(content))</li>\n"
                continue
            }

            // --- ordered list ---
            if trimmed.range(of: #"^\d+\.\s+"#, options: .regularExpression) != nil {
                if !inList || listTag != "ol" {
                    closeList(&html, &inList, &listTag)
                    html += "<ol>\n"
                    inList = true
                    listTag = "ol"
                }
                let content = trimmed.replacingOccurrences(
                    of: #"^\d+\.\s+"#, with: "", options: .regularExpression)
                html += "<li>\(inline(content))</li>\n"
                continue
            }

            // --- paragraph ---
            closeList(&html, &inList, &listTag)
            html += "<p>\(inline(trimmed))</p>\n"
        }

        if inCodeBlock { html += "</code></pre>\n" }
        closeList(&html, &inList, &listTag)
        return html
    }

    // MARK: - Helpers

    private static func headingLevel(_ line: String) -> Int? {
        var level = 0
        for ch in line {
            if ch == "#" { level += 1 } else { break }
        }
        guard (1...6).contains(level),
              line.dropFirst(level).first == " " else { return nil }
        return level
    }

    private static func closeList(_ html: inout String, _ inList: inout Bool, _ tag: inout String) {
        guard inList else { return }
        html += "</\(tag)>\n"
        inList = false
        tag = ""
    }

    private static func escapeHTML(_ text: String) -> String {
        text.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private static func inline(_ text: String) -> String {
        var s = escapeHTML(text)
        // inline code (before bold/italic so backtick content is not processed)
        s = s.replacingOccurrences(of: #"`([^`]+)`"#, with: "<code>$1</code>",
                                   options: .regularExpression)
        // bold
        s = s.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "<strong>$1</strong>",
                                   options: .regularExpression)
        s = s.replacingOccurrences(of: #"__(.+?)__"#, with: "<strong>$1</strong>",
                                   options: .regularExpression)
        // italic
        s = s.replacingOccurrences(of: #"\*(.+?)\*"#, with: "<em>$1</em>",
                                   options: .regularExpression)
        s = s.replacingOccurrences(of: #"\b_(.+?)_\b"#, with: "<em>$1</em>",
                                   options: .regularExpression)
        // strikethrough
        s = s.replacingOccurrences(of: #"~~(.+?)~~"#, with: "<del>$1</del>",
                                   options: .regularExpression)
        // links
        s = s.replacingOccurrences(of: #"\[([^\]]+)\]\(([^)]+)\)"#,
                                   with: #"<a href="$2">$1</a>"#,
                                   options: .regularExpression)
        return s
    }
}
