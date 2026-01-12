import Foundation
import OSLog
import Combine
@MainActor
final class GameViewModel: ObservableObject {
    @Published var currentQuestion: QuizQuestion?
    @Published var currentQuestionIndex: Int = 0
    @Published var correctAnswersCount: Int = 0
    @Published var selectedAnswer: String?
    @Published var isAnswerCorrect: Bool?
    @Published var isGameFinished: Bool = false
    @Published var recentScores: [GameScore] = []
    @Published var userProgress: UserProgress?
    
    private var questions: [QuizQuestion] = []
    private let totalQuestions: Int = 10
    
    private let animalDataService: AnimalDataService
    private let gameService: GameService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AnimalApp", category: "Game")
    
    init(animalDataService: AnimalDataService, gameService: GameService) {
        self.animalDataService = animalDataService
        self.gameService = gameService
    }
    
    func startNewGame() {
        let allAnimals = animalDataService.fetchAllAnimals()
        guard allAnimals.count >= totalQuestions else {
            logger.error("Not enough animals to start game")
            return
        }
        
        let selectedAnimals = Array(allAnimals.shuffled().prefix(totalQuestions))
        questions = selectedAnimals.map { animal in
            generateQuestionForAnimal(animal)
        }
        
        currentQuestionIndex = 0
        correctAnswersCount = 0
        isGameFinished = false
        selectedAnswer = nil
        isAnswerCorrect = nil
        
        loadNextQuestion()
        logger.info("Started new game with \(self.totalQuestions) questions")
    }
    
    func selectAnswer(_ answer: String) {
        guard let question = currentQuestion, selectedAnswer == nil else { return }
        
        selectedAnswer = answer
        isAnswerCorrect = answer == question.correctAnswer
        
        if isAnswerCorrect == true {
            correctAnswersCount += 1
        }
        
        logger.info("Answer selected: correct=\(self.isAnswerCorrect ?? false)")
    }
    
    func nextQuestion() {
        currentQuestionIndex += 1
        selectedAnswer = nil
        isAnswerCorrect = nil
        
        if currentQuestionIndex < questions.count {
            loadNextQuestion()
        } else {
            finishGame()
        }
    }
    
    func loadRecentScores() {
        recentScores = gameService.fetchRecentScores()
    }
    
    func loadUserProgress() {
        userProgress = gameService.fetchUserProgress()
    }
    
    private func loadNextQuestion() {
        guard currentQuestionIndex < questions.count else { return }
        currentQuestion = questions[currentQuestionIndex]
    }
    
    private func finishGame() {
        isGameFinished = true
        gameService.saveGameScore(correctAnswers: correctAnswersCount, totalQuestions: totalQuestions)
        loadRecentScores()
        loadUserProgress()
        logger.info("Game finished: \(self.correctAnswersCount)/\(self.totalQuestions)")
    }
    
    private func generateQuestionForAnimal(_ animal: Animal) -> QuizQuestion {
        let allAnimals = animalDataService.fetchAllAnimals()
        let otherAnimals = allAnimals.filter { $0.id != animal.id }
        
        let questionTypes: [QuestionGenerationType] = [.name, .habitat, .scientificName]
        let selectedType = questionTypes.randomElement() ?? .name
        
        switch selectedType {
        case .name:
            let correctAnswer = animal.name
            let incorrectAnswers = otherAnimals.shuffled().prefix(3).map { $0.name }
            return QuizQuestion(
                animal: animal,
                question: "Какое животное изображено?",
                correctAnswer: correctAnswer,
                incorrectAnswers: Array(incorrectAnswers)
            )
            
        case .habitat:
            let correctAnswer = animal.habitat
            let allHabitats = Set(otherAnimals.map { $0.habitat })
            let incorrectAnswers = Array(allHabitats).filter { $0 != correctAnswer }.shuffled().prefix(3)
            return QuizQuestion(
                animal: animal,
                question: "Где обитает \(animal.name)?",
                correctAnswer: correctAnswer,
                incorrectAnswers: Array(incorrectAnswers)
            )
            
        case .scientificName:
            let correctAnswer = animal.scientificName
            let incorrectAnswers = otherAnimals.shuffled().prefix(3).map { $0.scientificName }
            return QuizQuestion(
                animal: animal,
                question: "Какое научное название у \(animal.name)?",
                correctAnswer: correctAnswer,
                incorrectAnswers: Array(incorrectAnswers)
            )
        }
    }
}

private enum QuestionGenerationType {
    case name
    case habitat
    case scientificName
}

