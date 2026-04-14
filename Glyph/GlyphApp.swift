import SwiftUI

@main
struct GlyphApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: GlyphDocument()) { file in
            EditorView(document: file.$document)
        }
    }
}
