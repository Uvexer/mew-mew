import CoreData
import OSLog

final class AnimalDataService {
    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AnimalApp", category: "AnimalData")
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchAllAnimals() -> [Animal] {
        let fetchRequest: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \AnimalEntity.name, ascending: true)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { Animal(from: $0) }
        } catch {
            logger.error("Failed to fetch animals: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchFavoriteAnimals() -> [Animal] {
        let fetchRequest: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \AnimalEntity.name, ascending: true)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { Animal(from: $0) }
        } catch {
            logger.error("Failed to fetch favorite animals: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchAnimalsByCategory(_ category: AnimalCategory) -> [Animal] {
        let fetchRequest: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \AnimalEntity.name, ascending: true)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { Animal(from: $0) }
        } catch {
            logger.error("Failed to fetch animals by category: \(error.localizedDescription)")
            return []
        }
    }
    
    func toggleFavorite(for animalId: UUID) {
        let fetchRequest: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", animalId as CVarArg)
        
        do {
            if let entity = try context.fetch(fetchRequest).first {
                entity.isFavorite.toggle()
                try context.save()
                logger.info("Toggled favorite for animal: \(entity.name ?? "unknown")")
            }
        } catch {
            logger.error("Failed to toggle favorite: \(error.localizedDescription)")
        }
    }
    
    func seedDataIfNeeded() {
        let fetchRequest: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                seedInitialData()
                logger.info("Initial animal data seeded")
            }
        } catch {
            logger.error("Failed to check for existing data: \(error.localizedDescription)")
        }
    }
    
    private func seedInitialData() {
        let animals: [(name: String, scientific: String, description: String, habitat: String, lifespan: String, fact: String, category: AnimalCategory, imageName: String)] = [
            (
                name: "Африканский слон",
                scientific: "Loxodonta africana",
                description: "Крупнейшее наземное млекопитающее на Земле. Обладает удивительным интеллектом и сложной социальной структурой.",
                habitat: "Саванны, леса и пустыни Африки",
                lifespan: "60-70 лет",
                fact: "Слоны могут распознавать себя в зеркале и оплакивать своих умерших сородичей",
                category: .mammal,
                imageName: "elephant"
            ),
            (
                name: "Бенгальский тигр",
                scientific: "Panthera tigris tigris",
                description: "Один из крупнейших представителей семейства кошачьих. Отличный охотник и пловец.",
                habitat: "Тропические леса и мангровые заросли Индии",
                lifespan: "10-15 лет в дикой природе",
                fact: "Рисунок полос у каждого тигра уникален, как отпечатки пальцев у человека",
                category: .mammal,
                imageName: "tiger"
            ),
            (
                name: "Императорский пингвин",
                scientific: "Aptenodytes forsteri",
                description: "Самый крупный и тяжелый из всех видов пингвинов. Приспособлен к экстремальным условиям Антарктики.",
                habitat: "Ледяные берега Антарктиды",
                lifespan: "15-20 лет",
                fact: "Самцы высиживают яйца в течение 2 месяцев без пищи при температуре до -40°C",
                category: .bird,
                imageName: "penguin"
            ),
            (
                name: "Беркут",
                scientific: "Aquila chrysaetos",
                description: "Могущественный хищник с острым зрением и невероятной скоростью пикирования.",
                habitat: "Горные районы и открытые пространства Северного полушария",
                lifespan: "20-30 лет",
                fact: "Беркут может разглядеть зайца с расстояния 3 километров",
                category: .bird,
                imageName: "eagle"
            ),
            (
                name: "Зелёная морская черепаха",
                scientific: "Chelonia mydas",
                description: "Крупная морская черепаха, питающаяся в основном водорослями и морской травой.",
                habitat: "Тропические и субтропические воды мирового океана",
                lifespan: "80-100 лет",
                fact: "Морские черепахи возвращаются откладывать яйца на тот же пляж, где сами вылупились",
                category: .reptile,
                imageName: "turtle"
            ),
            (
                name: "Королевская кобра",
                scientific: "Ophiophagus hannah",
                description: "Самая длинная ядовитая змея в мире. Единственная змея, строящая гнезда для яиц.",
                habitat: "Леса Южной и Юго-Восточной Азии",
                lifespan: "20 лет",
                fact: "Королевская кобра может поднять треть своего тела вертикально и смотреть человеку в глаза",
                category: .reptile,
                imageName: "cobra"
            ),
            (
                name: "Большая белая акула",
                scientific: "Carcharodon carcharias",
                description: "Один из крупнейших хищников океана с невероятной силой укуса и чувствительностью к электромагнитным полям.",
                habitat: "Прибрежные воды всех океанов",
                lifespan: "70+ лет",
                fact: "Акулы существуют на Земле уже более 400 миллионов лет",
                category: .fish,
                imageName: "shark"
            ),
            (
                name: "Рыба-клоун",
                scientific: "Amphiprioninae",
                description: "Яркая коралловая рыбка, живущая в симбиозе с морскими анемонами.",
                habitat: "Коралловые рифы Индийского и Тихого океанов",
                lifespan: "6-10 лет",
                fact: "Рыбы-клоуны рождаются самцами, но могут менять пол в течение жизни",
                category: .fish,
                imageName: "clownfish"
            ),
            (
                name: "Синий кит",
                scientific: "Balaenoptera musculus",
                description: "Крупнейшее животное, когда-либо существовавшее на Земле. Может весить до 200 тонн.",
                habitat: "Океаны всего мира",
                lifespan: "80-90 лет",
                fact: "Сердце синего кита размером с небольшой автомобиль и весит около 600 кг",
                category: .mammal,
                imageName: "whale"
            ),
            (
                name: "Красная панда",
                scientific: "Ailurus fulgens",
                description: "Очаровательное древесное млекопитающее, питающееся в основном бамбуком.",
                habitat: "Горные леса Гималаев",
                lifespan: "8-10 лет",
                fact: "Красная панда была открыта на 50 лет раньше большой панды",
                category: .mammal,
                imageName: "redpanda"
            ),
            (
                name: "Колибри",
                scientific: "Trochilidae",
                description: "Самая маленькая птица в мире с невероятной скоростью взмахов крыльев.",
                habitat: "Америка, от Аляски до Огненной Земли",
                lifespan: "3-5 лет",
                fact: "Колибри может летать задом наперёд и является единственной птицей, способной зависать в воздухе",
                category: .bird,
                imageName: "hummingbird"
            ),
            (
                name: "Хамелеон",
                scientific: "Chamaeleonidae",
                description: "Уникальная ящерица, способная менять цвет и имеющая независимо вращающиеся глаза.",
                habitat: "Леса Африки и Мадагаскара",
                lifespan: "5-10 лет",
                fact: "Хамелеоны меняют цвет не только для маскировки, но и для общения и терморегуляции",
                category: .reptile,
                imageName: "chameleon"
            )
        ]
        
        for animalData in animals {
            let entity = AnimalEntity(context: context)
            entity.id = UUID()
            entity.name = animalData.name
            entity.scientificName = animalData.scientific
            entity.animalDescription = animalData.description
            entity.habitat = animalData.habitat
            entity.lifespan = animalData.lifespan
            entity.fact = animalData.fact
            entity.category = animalData.category.rawValue
            entity.imageName = animalData.imageName
            entity.isFavorite = false
        }
        
        do {
            try context.save()
        } catch {
            logger.error("Failed to seed initial data: \(error.localizedDescription)")
        }
    }
}

