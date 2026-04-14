import SwiftUI

struct EditorView: View {
    @Binding var document: GlyphDocument
    @State private var showPreview = false

    var body: some View {
        Group {
            if showPreview {
                MarkdownPreview(text: document.text)
            } else {
                TextEditor(text: $document.text)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showPreview.toggle()
                    }
                } label: {
                    Image(systemName: showPreview ? "pencil" : "eye")
                }
            }
        }
    }
}
