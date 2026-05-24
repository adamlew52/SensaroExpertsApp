import SwiftUI
import WebKit
import Combine

// MARK: - Models

enum StateFilter: String, CaseIterable, Identifiable {
    case all        = "All States"
    case colorado   = "Colorado"
    case oregon     = "Oregon"
    case utah       = "Utah"
    case washington = "Washington"

    var id: String { rawValue }

    var queryValue: String {
        switch self {
        case .all:        return ""
        case .colorado:   return "COLORADO"
        case .oregon:     return "OREGON"
        case .utah:       return "UTAH"
        case .washington: return "WASHINGTON"
        }
    }

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

    var queryValue: String {
        switch self {
        case .relevance: return "relevance"
        case .titleAZ:   return "title"
        case .state:     return "state"
        }
    }
}

// MARK: - WebViewStore

class WebViewStore: ObservableObject {
    var webView: WKWebView?

    func load(_ url: URL) {
        let req = URLRequest(url: url,
                             cachePolicy: .reloadIgnoringLocalCacheData,
                             timeoutInterval: 30)
        webView?.load(req)
    }
}

// MARK: - ViewModel

@MainActor
class ForestryViewModel: ObservableObject {
    @Published var selectedState: StateFilter = .all
    @Published var sortOrder: SortOrder = .relevance
    @Published var searchText: String = ""
    @Published var isLoading: Bool = true
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    let baseURL = "https://www.sensaro.net/Experts/index.html"

    var currentURL: URL {
        var components = URLComponents(string: baseURL)!
        var queryItems: [URLQueryItem] = []
        if !selectedState.queryValue.isEmpty {
            queryItems.append(URLQueryItem(name: "state", value: selectedState.queryValue))
        }
        if sortOrder != .relevance {
            queryItems.append(URLQueryItem(name: "sort", value: sortOrder.queryValue))
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: searchText))
        }
        if !queryItems.isEmpty { components.queryItems = queryItems }
        return components.url!
    }
}
