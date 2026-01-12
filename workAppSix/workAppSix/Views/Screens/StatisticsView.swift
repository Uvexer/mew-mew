import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel: EntriesViewModel
    
    init(coreDataService: CoreDataService) {
        _viewModel = StateObject(wrappedValue: EntriesViewModel(coreDataService: coreDataService))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) {
                        if viewModel.statistics.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "chart.bar")
                                    .font(.system(size: geometry.size.width > 400 ? 60 : 48))
                                    .foregroundStyle(.secondary)
                                
                                Text("No statistics yet")
                                    .font(geometry.size.width > 400 ? .title2 : .title3)
                                    .foregroundStyle(.secondary)
                                
                                Text("Start tracking time to see your statistics")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, geometry.size.height * 0.2)
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                let totalTime = viewModel.statistics.reduce(0.0) { $0 + $1.totalDuration }
                                let totalEntries = viewModel.statistics.reduce(0) { $0 + $1.entriesCount }
                                
                                VStack(spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Total Tracked")
                                                .font(.headline)
                                                .foregroundStyle(.secondary)
                                            
                                            Text(totalTime.formattedDuration)
                                                .font(.system(size: geometry.size.width > 400 ? 36 : 28, weight: .bold, design: .rounded))
                                                .foregroundStyle(.primary)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 8) {
                                            Text("Total Entries")
                                                .font(.headline)
                                                .foregroundStyle(.secondary)
                                            
                                            Text("\(totalEntries)")
                                                .font(.system(size: geometry.size.width > 400 ? 36 : 28, weight: .bold, design: .rounded))
                                                .foregroundStyle(.primary)
                                        }
                                    }
                                    .padding(geometry.size.width > 400 ? 24 : 20)
                                    .background(Color.accentColor.opacity(0.1))
                                    .cornerRadius(16)
                                }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Projects")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    
                                    ForEach(viewModel.statistics, id: \.project.id) { stat in
                                        StatisticsCard(statistics: stat)
                                    }
                                }
                            }
                        }
                    }
                    .padding(geometry.size.width > 600 ? 24 : 16)
                }
            }
            .navigationTitle("Statistics")
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.calculateStatistics()
        }
    }
}

