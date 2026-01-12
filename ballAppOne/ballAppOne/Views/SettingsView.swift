import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gravity: Double
    @State private var bounciness: Double
    @State private var airResistance: Double
    
    let settings: PhysicsSettings
    let onSave: (PhysicsSettings) -> Void
    
    init(settings: PhysicsSettings, onSave: @escaping (PhysicsSettings) -> Void) {
        self.settings = settings
        self.onSave = onSave
        _gravity = State(initialValue: settings.gravity)
        _bounciness = State(initialValue: settings.bounciness)
        _airResistance = State(initialValue: settings.airResistance)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Gravity")
                            Spacer()
                            Text(String(format: "%.0f", gravity))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $gravity, in: 100...2000, step: 50)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Bounciness")
                            Spacer()
                            Text(String(format: "%.2f", bounciness))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $bounciness, in: 0...1, step: 0.05)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Air Resistance")
                            Spacer()
                            Text(String(format: "%.3f", airResistance))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $airResistance, in: 0.9...1, step: 0.005)
                    }
                } header: {
                    Text("Physics Parameters")
                } footer: {
                    Text("Adjust physics parameters to change game behavior")
                }
                
                Section {
                    Button {
                        gravity = PhysicsSettings.default.gravity
                        bounciness = PhysicsSettings.default.bounciness
                        airResistance = PhysicsSettings.default.airResistance
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset to Default")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newSettings = PhysicsSettings(
                            gravity: gravity,
                            bounciness: bounciness,
                            airResistance: airResistance
                        )
                        onSave(newSettings)
                        dismiss()
                    }
                }
            }
        }
    }
}

