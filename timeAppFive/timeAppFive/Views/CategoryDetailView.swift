import SwiftUI

struct CategoryDetailView: View {
    @StateObject private var viewModel: CategoryDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(category: CategoryModel) {
        let context = CoreDataStack.shared.viewContext
        let service = FormulaService(context: context)
        _viewModel = StateObject(wrappedValue: CategoryDetailViewModel(category: category, formulaService: service))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        CategoryProgressView(
                            category: viewModel.category,
                            learnedCount: viewModel.learnedCount,
                            totalCount: viewModel.formulas.count,
                            progress: viewModel.progress
                        )
                        .padding(.horizontal)
                        .padding(.top)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredFormulas) { formula in
                                NavigationLink(value: formula) {
                                    FormulaRowView(
                                        formula: formula,
                                        categoryColor: viewModel.category.color,
                                        onToggleLearned: {
                                            Task {
                                                await viewModel.toggleLearnedStatus(for: formula)
                                            }
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationDestination(for: FormulaModel.self) { formula in
                    FormulaDetailView(formula: formula, categoryColor: viewModel.category.color)
                        .onAppear {
                            Task {
                                await viewModel.updateLastViewed(for: formula)
                            }
                        }
                }
            }
        }
        .navigationTitle(viewModel.category.name)
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $viewModel.searchQuery, prompt: "Поиск формул")
        .task {
            await viewModel.loadFormulas()
        }
    }
}

struct CategoryProgressView: View {
    let category: CategoryModel
    let learnedCount: Int
    let totalCount: Int
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.08) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(category.color.opacity(0.2))
                            .frame(width: geometry.size.width * 0.18)
                        
                        Image(systemName: category.iconName)
                            .font(.system(size: geometry.size.width * 0.08))
                            .foregroundColor(category.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Прогресс изучения")
                            .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(learnedCount) из \(totalCount) формул")
                            .font(.system(size: geometry.size.width * 0.055, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: geometry.size.width * 0.07, weight: .bold))
                        .foregroundColor(category.color)
                }
                
                GeometryReader { progressGeometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: progressGeometry.size.height * 0.5)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: progressGeometry.size.height * 0.5)
                            .fill(
                                LinearGradient(
                                    colors: [category.color, category.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: progressGeometry.size.width * progress)
                    }
                }
                .frame(height: geometry.size.height * 0.15)
            }
            .padding(geometry.size.width * 0.04)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
        .aspectRatio(3, contentMode: .fit)
    }
}

