import SwiftUI
import Combine

@MainActor
class ArticleViewModel: ObservableObject {
    @Published var selectedState: StateFilter = .all
    @Published var sortOrder: SortOrder = .relevance
    @Published var searchText: String = ""
    @Published var results: [Article] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Run search immediately and on any change (debounced for text)
        Publishers.CombineLatest3(
            $selectedState,
            $sortOrder,
            $searchText.debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] state, sort, query in
            guard let self else { return }
            self.results = ArticleSearch.filter(
                articles: allArticles,
                state: state,
                sort: sort,
                query: query
            )
        }
        .store(in: &cancellables)

        // Initial load
        results = allArticles
    }

    var filtersActive: Bool {
        selectedState != .all || sortOrder != .relevance
    }

    func resetFilters() {
        selectedState = .all
        sortOrder = .relevance
        searchText = ""
    }
}
