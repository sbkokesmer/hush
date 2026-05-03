import SwiftUI
import SwiftData

struct AddSiteView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var urlString = ""
    @FocusState private var focus: Field?

    enum Field { case name, url }

    var body: some View {
        NavigationStack {
            Form {
                Section("Site name") {
                    TextField("e.g. Reddit", text: $name)
                        .focused($focus, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focus = .url }
                }
                Section("Website") {
                    TextField("reddit.com", text: $urlString)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focus, equals: .url)
                        .submitLabel(.done)
                        .onSubmit(save)
                }
                Section {
                    Label("Sites are opened in an isolated session.", systemImage: "lock.shield")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
            .navigationTitle("New Site")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save).disabled(!isValid)
                }
            }
            .onAppear { focus = .name }
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        guard isValid else { return }
        let site = Site(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            urlString: urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        context.insert(site)
        dismiss()
    }
}
