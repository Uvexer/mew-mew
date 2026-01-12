import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showingResult = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    if viewModel.isGameFinished {
                        gameResultView
                    } else if viewModel.currentQuestion != nil {
                        gamePlayView(geometry: geometry)
                    } else {
                        gameStartView
                    }
                }
            }
            .navigationTitle("Викторина")
        }
        .navigationViewStyle(.stack)
    }
    
    private var gameStartView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Викторина о животных")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Проверьте свои знания о животном мире!")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button {
                viewModel.startNewGame()
            } label: {
                Text("Начать игру")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
    
    private func gamePlayView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            progressBar
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 8)
            
            ScrollView {
                VStack(spacing: 20) {
                    if let question = viewModel.currentQuestion {
                        questionCard(question: question, geometry: geometry)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        
                        answersSection(question: question)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }
            }
            
            if viewModel.selectedAnswer != nil {
                nextButton
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
        }
    }
    
    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Вопрос \(viewModel.currentQuestionIndex + 1) из 10")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.correctAnswersCount) ✓")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(viewModel.currentQuestionIndex + 1) / 10, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
    
    private func questionCard(question: QuizQuestion, geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            ZStack {
                LinearGradient(
                    colors: gradientColors(for: question.animal.category),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                if let uiImage = UIImage(named: question.animal.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Text(question.animal.category.icon)
                        .font(.system(size: 80))
                }
            }
            .frame(width: geometry.size.width - 64, height: (geometry.size.width - 64) * 0.7)
            .clipped()
            .cornerRadius(16)
            
            Text(question.question)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func gradientColors(for category: AnimalCategory) -> [Color] {
        switch category {
        case .mammal: return [.blue, .cyan]
        case .bird: return [.orange, .yellow]
        case .reptile: return [.green, .mint]
        case .fish: return [.blue, .purple]
        }
    }
    
    private func answersSection(question: QuizQuestion) -> some View {
        VStack(spacing: 12) {
            ForEach(question.allAnswers, id: \.self) { answer in
                AnswerButton(
                    answer: answer,
                    isSelected: viewModel.selectedAnswer == answer,
                    isCorrect: answer == question.correctAnswer,
                    showResult: viewModel.selectedAnswer != nil
                ) {
                    viewModel.selectAnswer(answer)
                }
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }
    
    private var nextButton: some View {
        Button {
            viewModel.nextQuestion()
        } label: {
            Text("Продолжить")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(16)
        }
    }
    
    private var gameResultView: some View {
        ScrollView {
            VStack(spacing: 24) {
                resultIcon
                    .padding(.top, 24)
                
                Text("Игра завершена!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                scoreCard
                    .padding(.horizontal, 32)
                
                // место под кнопку, которая будет inset'ом снизу
                Color.clear
                    .frame(height: 1)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 12)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                viewModel.startNewGame()
            } label: {
                Text("Играть ещё")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 32)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.ultraThinMaterial)
            .transaction { transaction in
                transaction.animation = nil
            }
        }
    }
    
    private var resultIcon: some View {
        let percentage = Double(viewModel.correctAnswersCount) / 10.0 * 100
        let icon: String
        let color: Color
        
        if percentage >= 80 {
            icon = "star.fill"
            color = .yellow
        } else if percentage >= 60 {
            icon = "hand.thumbsup.fill"
            color = .green
        } else {
            icon = "book.fill"
            color = .blue
        }
        
        return Image(systemName: icon)
            .font(.system(size: 80))
            .foregroundColor(color)
    }
    
    private var scoreCard: some View {
        VStack(spacing: 16) {
            Text("\(viewModel.correctAnswersCount) из 10")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.blue)
            
            Text("правильных ответов")
                .font(.title3)
                .foregroundColor(.secondary)
            
            let percentage = Double(viewModel.correctAnswersCount) / 10.0 * 100
            Text(String(format: "%.0f%%", percentage))
                .font(.title)
                .fontWeight(.semibold)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

struct AnswerButton: View {
    let answer: String
    let isSelected: Bool
    let isCorrect: Bool
    let showResult: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(.plain) // убираем системную анимацию/подсветку Button
        .disabled(showResult)
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private var content: some View {
        HStack {
            Text(answer)
                .font(.body)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Резервируем место для иконки, чтобы layout не менялся
            Group {
                if showResult {
                    if isSelected && isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if isSelected && !isCorrect {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    } else if !isSelected && isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Color.clear.frame(width: 24, height: 24)
                    }
                } else {
                    Color.clear.frame(width: 24, height: 24)
                }
            }
            .frame(width: 24, height: 24)
        }
        .padding()
        .background(backgroundColor)
        .foregroundColor(textColor)
        .cornerRadius(12)
        .contentShape(Rectangle())
        // Всегда рисуем рамку, но меняем толщину/цвет без появления/исчезновения overlay
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: showResult ? 2 : 0)
        )
        .transaction { transaction in
            transaction.animation = nil
        }
    }
    
    private var backgroundColor: Color {
        if showResult {
            if isSelected && isCorrect {
                return Color.green.opacity(0.2)
            } else if isSelected && !isCorrect {
                return Color.red.opacity(0.2)
            } else if !isSelected && isCorrect {
                return Color.green.opacity(0.1)
            }
        }
        return Color(.systemGray6)
    }
    
    private var textColor: Color {
        if showResult {
            if isSelected && isCorrect {
                return .green
            } else if isSelected && !isCorrect {
                return .red
            } else if !isSelected && isCorrect {
                return .green
            }
        }
        return .primary
    }
    
    private var borderColor: Color {
        if showResult {
            if isSelected && isCorrect {
                return .green
            } else if isSelected && !isCorrect {
                return .red
            } else if !isSelected && isCorrect {
                return .green
            }
        }
        return .clear
    }
}

