import SwiftUI

@main
struct assistApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Import Data") {
                    viewModel.importNotes()
                }
                .keyboardShortcut("I", modifiers: [.command, .shift])

                Button("Export Data") {
                    viewModel.exportNotes()
                }
                .keyboardShortcut("E", modifiers: [.command, .shift])
            }
        }
    }

    @StateObject private var viewModel = NoteViewModel()
}
