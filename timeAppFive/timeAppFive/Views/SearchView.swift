import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    
    init() {
        let context = CoreDataStack.shared.viewContext
        let service = FormulaService(context: context)
        _viewModel = StateObject(wrappedValue: SearchViewModel(formulaService: service, context: context))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.searchQuery.isEmpty {
                    EmptySearchStateView()
                } else if viewModel.isSearching {
                    ProgressView()
                } else if viewModel.searchResults.isEmpty {
                    NoResultsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.searchResults) { formula in
                                NavigationLink(value: formula) {
                                    SearchResultRowView(formula: formula)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    .navigationDestination(for: FormulaModel.self) { formula in
                        FormulaDetailView(formula: formula, categoryColor: .blue)
                    }
                }
            }
            .navigationTitle("Поиск")
            .searchable(text: $viewModel.searchQuery, prompt: "Найти формулу...")
            .onChange(of: viewModel.searchQuery) { _, _ in
                viewModel.search()
            }
        }
    }
}

struct EmptySearchStateView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.03) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: geometry.size.width * 0.15))
                    .foregroundColor(.secondary)
                
                Text("Начните поиск")
                    .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Введите название формулы или предмет")
                    .font(.system(size: geometry.size.width * 0.035))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct NoResultsView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.03) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: geometry.size.width * 0.15))
                    .foregroundColor(.secondary)
                
                Text("Ничего не найдено")
                    .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Попробуйте изменить запрос")
                    .font(.system(size: geometry.size.width * 0.035))
                    .foregroundColor(.secondary)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct SearchResultRowView: View {
    let formula: FormulaModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: geometry.size.height * 0.1) {
                HStack {
                    Text(formula.name)
                        .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if formula.isLearned {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: geometry.size.width * 0.05))
                            .foregroundColor(.green)
                    }
                }
                
                Text(formula.formulaText)
                    .font(.system(size: geometry.size.width * 0.038, design: .monospaced))
                    .foregroundColor(.blue)
                    .lineLimit(1)
                
                Text(formula.descriptionText)
                    .font(.system(size: geometry.size.width * 0.032))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(geometry.size.width * 0.04)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
        .aspectRatio(4, contentMode: .fit)
    }
}

