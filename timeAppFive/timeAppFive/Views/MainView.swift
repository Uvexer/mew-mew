import SwiftUI
import CoreData

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    
    init(categoryService: CategoryServiceProtocol, context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: MainViewModel(categoryService: categoryService, context: context))
    }
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Поиск", systemImage: "magnifyingglass")
                }
                .tag(1)
            
       
               
        }
        .task {
            await viewModel.loadCategories()
        }
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ProgressHeaderView(
                                totalFormulas: viewModel.totalFormulas,
                                learnedFormulas: viewModel.totalLearned,
                                progress: viewModel.overallProgress
                            )
                            .padding(.horizontal)
                            .padding(.top)
                            // GeometryReader внутри ScrollView может некорректно рассчитывать высоту.
                            // Явно фиксируем высоту хедера, чтобы контент ниже не наезжал.
                            .frame(height: progressHeaderHeight)
                            
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.categories) { category in
                                    NavigationLink(value: category) {
                                        CategoryCardView(category: category)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                    .navigationDestination(for: CategoryModel.self) { category in
                        CategoryDetailView(category: category)
                    }
                }
            }
            .navigationTitle("Formula Hub")
            .refreshable {
                await viewModel.refreshCategories()
            }
        }
    }
    
    private var progressHeaderHeight: CGFloat {
       
        let screenWidth = UIScreen.main.bounds.width
        let horizontalPadding: CGFloat = 32 // .padding(.horizontal) == 16*2
        let availableWidth = max(0, screenWidth - horizontalPadding)
      
        return max(340, min(520, availableWidth * 0.98))
    }
}

