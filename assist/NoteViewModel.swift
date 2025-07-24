import AppKit
import Foundation
import UniformTypeIdentifiers

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var inputText: String = ""
    @Published var tags: [String] = []

    private let savePath = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("notes.json")

    var savePathDisplay: String {
        savePath.path
    }

    init(previewMode: Bool = false) {
        if previewMode {
            notes = [
                Note(id: UUID(), text: "Sample note 1", timestamp: Date()),
                Note(id: UUID(), text: "Another preview!", timestamp: Date().addingTimeInterval(-3600))
            ]
            tags = ["#swift", "#todo"]
        } else {
            loadNotes()
            notes.sort { $0.timestamp < $1.timestamp }
        }
    }

    func addNote() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newNote = Note(id: UUID(), text: trimmed, timestamp: Date())
        notes.append(newNote)
        inputText = ""
        saveNotes()
    }

    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            try FileManager.default.createDirectory(
                at: savePath.deletingLastPathComponent(),
                withIntermediateDirectories: true,
                attributes: nil
            )
            try data.write(to: savePath)
        } catch {
            print("Error saving notes: \(error.localizedDescription)")
        }
    }

    func loadNotes() {
        guard FileManager.default.fileExists(atPath: savePath.path) else { return }

        do {
            let data = try Data(contentsOf: savePath)
            notes = try JSONDecoder().decode([Note].self, from: data)
        } catch {
            print("Error loading notes: \(error.localizedDescription)")
        }
    }
}

extension NoteViewModel {
    func exportNotes() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "notes.json"

        if panel.runModal() == .OK, let url = panel.url {
            do {
                let data = try JSONEncoder().encode(notes)
                try data.write(to: url)
            } catch {
                print("Export failed: \(error)")
            }
        }
    }

    func importNotes() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            do {
                let data = try Data(contentsOf: url)
                let imported = try JSONDecoder().decode([Note].self, from: data)
                notes = imported
                saveNotes()
            } catch {
                print("Import failed: \(error)")
            }
        }
    }
}
