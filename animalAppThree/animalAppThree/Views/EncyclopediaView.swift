import SwiftUI

struct EncyclopediaView: View {
    @ObservedObject var viewModel: EncyclopediaViewModel
    @State private var selectedAnimal: Animal?
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        searchBar
                            .padding(.horizontal)
                            .padding(.top)
                        
                        categoryFilter
                            .padding(.vertical)
                        
                        animalGrid(geometry: geometry)
                            .padding(.horizontal)
                    }
                }
                .navigationTitle("Животные мира")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.toggleFavoritesFilter()
                        } label: {
                            Image(systemName: viewModel.showFavoritesOnly ? "heart.fill" : "heart")
                                .foregroundColor(viewModel.showFavoritesOnly ? .red : .primary)
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .sheet(item: $selectedAnimal) { animal in
            AnimalDetailView(animal: viewModel.animals.first(where: { $0.id == animal.id }) ?? animal, onFavoriteToggle: {
                viewModel.toggleFavorite(for: animal)
                if let updatedAnimal = viewModel.animals.first(where: { $0.id == animal.id }) {
                    selectedAnimal = updatedAnimal
                }
            })
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Поиск животных...", text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.updateSearchText($0) }
            ))
            .textFieldStyle(.plain)
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.updateSearchText("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    title: "Все",
                    icon: "🌍",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectCategory(nil)
                }
                
                ForEach(AnimalCategory.allCases) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func animalGrid(geometry: GeometryProxy) -> some View {
        let columns = adaptiveColumns(for: geometry.size.width)
        
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.filteredAnimals) { animal in
                AnimalCard(animal: animal)
                    .onTapGesture {
                        selectedAnimal = animal
                    }
            }
        }
    }
    
    private func adaptiveColumns(for width: CGFloat) -> [GridItem] {
        let minColumnWidth: CGFloat = 150
        let spacing: CGFloat = 16
        let horizontalPadding: CGFloat = 32
        let availableWidth = width - horizontalPadding
        let columnCount = max(1, Int(availableWidth / (minColumnWidth + spacing)))
        
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)
    }
}

