import SwiftUI

// MARK: - Sensaro Forest Theme
// Sourced directly from the site's CSS variables:
// --forest-black: #070d09   --forest-deep: #0a1410
// --forest-dark:  #0f2018   --forest-muted: #1d4430
// --pine:         #22c55e   --ember: #f59e0b
// --sky:          #38bdf8   --text: #e0f0e5
// --text-dim:     #b0cfbc   --text-muted: #6c8b74

extension Color {
    static let forestBlack  = Color(hex: "#070d09")
    static let forestDeep   = Color(hex: "#0a1410")
    static let forestDark   = Color(hex: "#0f2018")
    static let forestMuted  = Color(hex: "#1d4430")
    static let forestBorder = Color(hex: "#22c55e").opacity(0.2)
    static let pine         = Color(hex: "#22c55e")
    static let ember        = Color(hex: "#f59e0b")
    static let sky          = Color(hex: "#38bdf8")
    static let textPrimary  = Color(hex: "#e0f0e5")
    static let textDim      = Color(hex: "#b0cfbc")
    static let textMuted    = Color(hex: "#6c8b74")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct RootView: View {
    @StateObject private var vm = ArticleViewModel()
    @State private var showFilters = false
    @State private var showSearch  = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.forestBlack.ignoresSafeArea()
                VStack(spacing: 0) {
                    topBar
                    if showSearch {
                        SearchBar(text: $vm.searchText)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    articleList
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterSheetView(viewModel: vm)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .tint(.pine)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "tree.fill")
                .foregroundColor(.pine)
            Text("Sensaro Experts")
                .font(.headline).fontWeight(.bold)
                .foregroundColor(.textPrimary)
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showSearch.toggle()
                    if !showSearch { vm.searchText = "" }
                }
            } label: {
                Image(systemName: showSearch ? "xmark.circle.fill" : "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundColor(.textDim)
            }
            Button { showFilters = true } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(vm.filtersActive ? .fill : .none)
                    .foregroundColor(vm.filtersActive ? .pine : .textDim)
                    .font(.system(size: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.forestDeep)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.forestBorder),
            alignment: .bottom
        )
    }

    // MARK: - Article List

    private var articleList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Result count pill — matches site's .stats style
                HStack {
                    Text("\(vm.results.count) article\(vm.results.count == 1 ? "" : "s")")
                        .font(.caption).fontWeight(.semibold)
                        .foregroundColor(.pine)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Color.forestMuted)
                        .clipShape(Capsule())
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                if vm.results.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.textMuted)
                        Text("No matching articles")
                            .foregroundColor(.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    ForEach(vm.results) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            ArticleRow(article: article)
                        }
                        .buttonStyle(.plain)

                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.forestBorder)
                            .padding(.leading, 16)
                    }
                }
            }
        }
        .background(Color.forestBlack)
    }
}

// MARK: - Article Row

struct ArticleRow: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.system(size: 15))
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundColor(.textPrimary)

            HStack(spacing: 6) {
                // State badge — matches site's .state-tag
                Text(article.stateDisplay)
                    .font(.caption2).fontWeight(.bold)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color.pine.opacity(0.15))
                    .foregroundColor(.pine)
                    .overlay(
                        Capsule().stroke(Color.forestBorder, lineWidth: 1)
                    )
                    .clipShape(Capsule())

                // Keyword chips — matches site's .keyword-badge
                ForEach(article.keywords.prefix(3), id: \.self) { kw in
                    Text(kw)
                        .font(.caption2)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.sky.opacity(0.1))
                        .foregroundColor(.sky)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.forestDark)
    }
}

#Preview {
    RootView()
}
