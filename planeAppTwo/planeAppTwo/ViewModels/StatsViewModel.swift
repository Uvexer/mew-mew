import Foundation
import Combine
import OSLog

@MainActor
final class StatsViewModel: ObservableObject {
    @Published var flights: [Flight] = []
    @Published var settings: GameSettings?
    
    private let dataService: DataService
    private let logger = Logger(subsystem: "com.planeapp", category: "stats")
    
    init(dataService: DataService) {
        self.dataService = dataService
    }
    
    func loadData() {
        let flightEntities = dataService.fetchFlights()
        flights = flightEntities.map { Flight(from: $0) }
        
        let settingsEntity = dataService.getSettings()
        settings = GameSettings(from: settingsEntity)
        
        logger.info("Loaded \(self.flights.count) flights")
    }
    
    func deleteAllFlights() {
        dataService.deleteAllFlights()
        loadData()
        logger.info("All flights deleted")
    }
    
    var totalScore: Int {
        flights.reduce(0) { $0 + $1.score }
    }
    
    var totalDuration: Int {
        flights.reduce(0) { $0 + $1.duration }
    }
    
    var averageScore: Int {
        guard !flights.isEmpty else { return 0 }
        return totalScore / flights.count
    }
}

