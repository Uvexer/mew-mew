import SwiftUI

struct EntriesView: View {
    @StateObject private var viewModel: EntriesViewModel
    
    init(coreDataService: CoreDataService) {
        _viewModel = StateObject(wrappedValue: EntriesViewModel(coreDataService: coreDataService))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) {
                        DatePicker(
                            "Select Date",
                            selection: $viewModel.selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding(.horizontal, geometry.size.width > 600 ? 24 : 16)
                        
                        if viewModel.entries.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "clock")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                                
                                Text("No entries for this date")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 40)
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Time Entries")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, geometry.size.width > 600 ? 24 : 16)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.entries) { entry in
                                        TimeEntryCard(entry: entry)
                                            .contextMenu {
                                                Button(action: {
                                                    handleEditEntry(entry)
                                                }) {
                                                    Label("Edit", systemImage: "pencil")
                                                }
                                                
                                                Button(role: .destructive, action: {
                                                    Task {
                                                        await viewModel.deleteEntry(entry)
                                                    }
                                                }) {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal, geometry.size.width > 600 ? 24 : 16)
                            }
                        }
                        
                        if !viewModel.entries.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Day Summary")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                let totalDuration = viewModel.entries.reduce(0.0) { $0 + $1.duration }
                                
                                HStack {
                                    Label("Total Time", systemImage: "clock.fill")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(totalDuration.formattedDuration)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                }
                                .padding()
                                .background(Color(uiColor: .systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                            .padding(.horizontal, geometry.size.width > 600 ? 24 : 16)
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Entries")
            .sheet(item: $viewModel.editingEntry) { entry in
                EditEntrySheet(
                    entry: entry,
                    onSave: { startDate, endDate, notes in
                        Task {
                            await viewModel.updateEntry(entry, startDate: startDate, endDate: endDate, notes: notes)
                        }
                    }
                )
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func handleEditEntry(_ entry: TimeEntry) {
        let entries = viewModel.coreDataService.fetchTimeEntries()
        if let entity = entries.first(where: { $0.id == entry.id }) {
            viewModel.editingEntry = entity
        }
    }
}

struct EditEntrySheet: View {
    let entry: TimeEntryEntity
    let onSave: (Date, Date?, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var hasEndDate: Bool
    @State private var notes: String
    
    init(entry: TimeEntryEntity, onSave: @escaping (Date, Date?, String?) -> Void) {
        self.entry = entry
        self.onSave = onSave
        
        let start = entry.startDate ?? Date()
        let end = entry.endDate ?? Date()
        
        _startDate = State(initialValue: start)
        _endDate = State(initialValue: end)
        _hasEndDate = State(initialValue: entry.endDate != nil)
        _notes = State(initialValue: entry.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Start", selection: $startDate)
                } header: {
                    Text("Start Time")
                }
                
                Section {
                    Toggle("Has end time", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("End", selection: $endDate)
                    }
                } header: {
                    Text("End Time")
                }
                
                Section {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let finalEndDate = hasEndDate ? endDate : nil
                        let finalNotes = notes.isEmpty ? nil : notes
                        onSave(startDate, finalEndDate, finalNotes)
                        dismiss()
                    }
                }
            }
        }
    }
}

