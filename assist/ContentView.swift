import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: NoteViewModel

    var body: some View {
        VStack(spacing: 12) {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.notes) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.text)
                                .font(.body)
                            Text(note.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .id(note.id) // 🆔 Important for scrolling
                    }
                }
                .onChange(of: viewModel.notes.count) {
                    guard let last = viewModel.notes.last else { return }
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            if !viewModel.tags.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(viewModel.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            HStack {
                TextField("Enter note...", text: $viewModel.inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        viewModel.addNote()
                    }

                Button("Post") {
                    viewModel.addNote()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 500)
    }
}

#Preview {
    ContentView(viewModel: NoteViewModel(previewMode: true))
}
