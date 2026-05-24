import Foundation

// MARK: - Article Model

struct Article: Identifiable, Hashable {
    let id = UUID()
    let state: String
    let topic: String
    let title: String
    let url: String
    let keywords: [String]
    let totalMentions: Int

    var articleURL: URL? {
        URL(string: "https://www.sensaro.net\(url)")
    }

    var stateDisplay: String { state.uppercased() }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Filters

enum StateFilter: String, CaseIterable, Identifiable {
    case all        = "All States"
    case colorado   = "Colorado"
    case oregon     = "Oregon"
    case utah       = "Utah"
    case washington = "Washington"

    var id: String { rawValue }
    var queryValue: String { self == .all ? "all" : rawValue.lowercased() }

    var icon: String {
        switch self {
        case .all:        return "map"
        case .colorado:   return "mountain.2"
        case .oregon:     return "tree"
        case .utah:       return "sun.max"
        case .washington: return "cloud.rain"
        }
    }
}

enum SortOrder: String, CaseIterable, Identifiable {
    case relevance = "Relevance"
    case titleAZ   = "Title A–Z"
    case state     = "State"
    var id: String { rawValue }
}

// MARK: - Search Engine (mirrors the JS logic exactly)

enum ArticleSearch {
    static func filter(
        articles: [Article],
        state: StateFilter,
        sort: SortOrder,
        query: String
    ) -> [Article] {
        let term = query.trimmingCharacters(in: .whitespaces).lowercased()

        var results = articles.filter { art in
            if state != .all && art.state != state.queryValue { return false }
            if term.isEmpty { return true }
            let kwMatch    = art.keywords.contains { $0.lowercased().contains(term) }
            let titleMatch = art.title.lowercased().contains(term)
            let stateMatch = art.state.lowercased().contains(term)
            let topicMatch = art.topic.lowercased().contains(term)
            return kwMatch || titleMatch || stateMatch || topicMatch
        }

        switch sort {
        case .relevance:
            results.sort { relevanceScore($0, term: term) > relevanceScore($1, term: term) }
        case .titleAZ:
            results.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .state:
            results.sort {
                if $0.state != $1.state { return $0.state < $1.state }
                return $0.title.localizedCompare($1.title) == .orderedAscending
            }
        }
        return results
    }

    private static func relevanceScore(_ article: Article, term: String) -> Int {
        if term.isEmpty { return article.totalMentions }
        var score = 0
        for kw in article.keywords where kw.lowercased().contains(term) { score += 3 }
        if article.title.lowercased().contains(term) { score += 5 }
        if article.state.lowercased().contains(term) { score += 2 }
        return score
    }
}
