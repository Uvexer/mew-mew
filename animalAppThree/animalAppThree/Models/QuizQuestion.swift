import Foundation

struct QuizQuestion {
    let animal: Animal
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    var allAnswers: [String] {
        ([correctAnswer] + incorrectAnswers).shuffled()
    }
}

enum QuestionType: CaseIterable {
    case habitat
    case lifespan
    case scientificName
    case fact
    
    func generateQuestion(for animal: Animal) -> QuizQuestion {
        switch self {
        case .habitat:
            return QuizQuestion(
                animal: animal,
                question: "Где обитает \(animal.name)?",
                correctAnswer: animal.habitat,
                incorrectAnswers: []
            )
        case .lifespan:
            return QuizQuestion(
                animal: animal,
                question: "Какова продолжительность жизни животного \(animal.name)?",
                correctAnswer: animal.lifespan,
                incorrectAnswers: []
            )
        case .scientificName:
            return QuizQuestion(
                animal: animal,
                question: "Какое научное название у животного \(animal.name)?",
                correctAnswer: animal.scientificName,
                incorrectAnswers: []
            )
        case .fact:
            return QuizQuestion(
                animal: animal,
                question: "Какой интересный факт связан с \(animal.name)?",
                correctAnswer: animal.fact,
                incorrectAnswers: []
            )
        }
    }
}

