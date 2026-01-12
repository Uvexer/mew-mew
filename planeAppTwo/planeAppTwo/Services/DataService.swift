import CoreData
import Combine
import OSLog

@MainActor
final class DataService: ObservableObject {
    private let persistenceController: PersistenceController
    private let logger = Logger(subsystem: "com.planeapp", category: "dataservice")
    
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
    
    func saveFlight(score: Int, duration: Int, obstaclesAvoided: Int) {
        let flight = FlightEntity(context: viewContext)
        flight.id = UUID()
        flight.date = Date()
        flight.score = Int32(score)
        flight.duration = Int32(duration)
        flight.obstaclesAvoided = Int32(obstaclesAvoided)
        
        persistenceController.save()
        logger.info("Flight saved with score: \(score)")
        
        updateTotalFlights()
        updateHighScore(score)
    }
    
    func fetchFlights() -> [FlightEntity] {
        let request = FlightEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FlightEntity.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            logger.error("Failed to fetch flights: \(error.localizedDescription)")
            return []
        }
    }
    
    func getSettings() -> GameSettingsEntity {
        let request = GameSettingsEntity.fetchRequest()
        
        do {
            if let settings = try viewContext.fetch(request).first {
                return settings
            } else {
                return createDefaultSettings()
            }
        } catch {
            logger.error("Failed to fetch settings: \(error.localizedDescription)")
            return createDefaultSettings()
        }
    }
    
    func updateSettings(difficulty: Int16? = nil, soundEnabled: Bool? = nil) {
        let settings = getSettings()
        
        if let difficulty = difficulty {
            settings.difficulty = difficulty
        }
        
        if let soundEnabled = soundEnabled {
            settings.soundEnabled = soundEnabled
        }
        
        persistenceController.save()
        logger.info("Settings updated")
    }
    
    private func createDefaultSettings() -> GameSettingsEntity {
        let settings = GameSettingsEntity(context: viewContext)
        settings.difficulty = 1
        settings.soundEnabled = true
        settings.highScore = 0
        settings.totalFlights = 0
        
        persistenceController.save()
        return settings
    }
    
    private func updateTotalFlights() {
        let settings = getSettings()
        settings.totalFlights += 1
        persistenceController.save()
    }
    
    private func updateHighScore(_ score: Int) {
        let settings = getSettings()
        if score > settings.highScore {
            settings.highScore = Int32(score)
            persistenceController.save()
            logger.info("New high score: \(score)")
        }
    }
    
    func deleteAllFlights() {
        let request = FlightEntity.fetchRequest()
        
        do {
            let flights = try viewContext.fetch(request)
            flights.forEach { viewContext.delete($0) }
            
            let settings = getSettings()
            settings.highScore = 0
            settings.totalFlights = 0
            
            persistenceController.save()
            logger.info("All flights and statistics deleted")
        } catch {
            logger.error("Failed to delete flights: \(error.localizedDescription)")
        }
    }
}

