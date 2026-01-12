import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel
    @State private var showingDeleteAlert = false
    
    init(dataService: DataService) {
        _viewModel = StateObject(wrappedValue: StatsViewModel(dataService: dataService))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        if let settings = viewModel.settings {
                            overallStatsSection(settings: settings, geometry: geometry)
                        }
                        
                        flightHistorySection(geometry: geometry)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadData()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !viewModel.flights.isEmpty {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .alert("Delete All Flights?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteAllFlights()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.4)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private func overallStatsSection(settings: GameSettings, geometry: GeometryProxy) -> some View {
        VStack(spacing: 15) {
            Text("Overall Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                StatCard(title: "High Score", value: "\(settings.highScore)", icon: "trophy.fill", color: .yellow)
                StatCard(title: "Total Flights", value: "\(settings.totalFlights)", icon: "airplane", color: .green)
                StatCard(title: "Avg Score", value: "\(viewModel.averageScore)", icon: "chart.line.uptrend.xyaxis", color: .orange)
                StatCard(title: "Total Score", value: "\(viewModel.totalScore)", icon: "star.fill", color: .blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.2))
        )
    }
    
    private func flightHistorySection(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Flight History")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            if viewModel.flights.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.flights.prefix(20)) { flight in
                    FlightRow(flight: flight)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No flights yet")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Start your first flight to see statistics here")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.black.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
        )
    }
}

struct FlightRow: View {
    let flight: Flight
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Text(flightDateFormatted)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(flightTimeFormatted)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("\(flight.score)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Text("\(flight.duration)s")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
        .padding(.horizontal)
    }
    
    private var flightDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: flight.date)
    }
    
    private var flightTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: flight.date)
    }
}

