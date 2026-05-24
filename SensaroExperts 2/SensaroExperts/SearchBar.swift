import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textMuted)
            TextField("Search by state, topic, or keyword…", text: $text)
                .textFieldStyle(.plain)
                .submitLabel(.search)
                .focused($focused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .foregroundColor(.textPrimary)
                .tint(.pine)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textMuted)
                }
            }
        }
        .padding(10)
        .background(Color.forestDark)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.forestBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.forestDeep)
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(.forestBorder),
            alignment: .bottom
        )
        .onAppear { focused = true }
    }
}
