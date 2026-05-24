import SwiftUI

struct RootView: View {
    @StateObject private var vm = ArticleViewModel()
    @State private var showFilters = false
    @State private var showSearch = false
    @State private var selectedArticle: Article?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                topBar
                if showSearch {
                    SearchBar(text: $vm.searchText)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                articleList
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterSheetView(viewModel: vm)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .tint(.green)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "tree.fill")
                .foregroundColor(.green)
            Text("Sensaro Experts")
                .font(.headline).fontWeight(.bold)
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showSearch.toggle()
                    if !showSearch { vm.searchText = "" }
                }
            } label: {
                Image(systemName: showSearch ? "xmark.circle.fill" : "magnifyingglass")
                    .font(.system(size: 18))
            }
            Button { showFilters = true } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(vm.filtersActive ? .fill : .none)
                    .foregroundColor(vm.filtersActive ? .green : .primary)
                    .font(.system(size: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: - Article List

    private var articleList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Result count header
                HStack {
                    Text("\(vm.results.count) article\(vm.results.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                if vm.results.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No matching articles")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    ForEach(vm.results) { article in
                        ArticleRow(article: article)
                            .contentShape(Rectangle())
                            .onTapGesture { selectedArticle = article }
                        Divider().padding(.leading, 16)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Article Row

struct ArticleRow: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(article.title)
                .font(.system(size: 15))
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundColor(.primary)

            HStack(spacing: 6) {
                // State badge
                Text(article.stateDisplay)
                    .font(.caption2).fontWeight(.bold)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .clipShape(Capsule())

                // Top keywords
                ForEach(article.keywords.prefix(3), id: \.self) { kw in
                    Text(kw)
                        .font(.caption2)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

#Preview {
    RootView()
}
