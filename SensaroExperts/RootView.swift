import SwiftUI
import Combine

struct RootView: View {
    @StateObject private var vm           = ForestryViewModel()
    @StateObject private var webViewStore = WebViewStore()
    @State private var showFilters        = false
    @State private var showSearch         = false
    @State private var searchCancellable: AnyCancellable?

    var filtersActive: Bool {
        vm.selectedState != .all || vm.sortOrder != .relevance
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Top navigation bar ──
            topBar

            // ── Search bar (slides in) ──
            if showSearch {
                SearchBar(text: $vm.searchText)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // ── Loading bar ──
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(.linear)
                    .tint(.green)
            }

            // ── Web content ──
            WebViewContainer(
                url: vm.currentURL,
                store: webViewStore,
                isLoading: $vm.isLoading,
                canGoBack: $vm.canGoBack,
                canGoForward: $vm.canGoForward
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Bottom bar ──
            bottomBar
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showFilters) {
            FilterSheetView(viewModel: vm)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .tint(.green)
        .onChange(of: vm.selectedState) { _, _ in webViewStore.load(vm.currentURL) }
        .onChange(of: vm.sortOrder)     { _, _ in webViewStore.load(vm.currentURL) }
        .onChange(of: vm.searchText) { _, _ in
            searchCancellable?.cancel()
            searchCancellable = Just(())
                .delay(for: .milliseconds(600), scheduler: RunLoop.main)
                .sink { webViewStore.load(vm.currentURL) }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "tree.fill")
                .foregroundColor(.green)
            Text("Sensaro Experts")
                .font(.headline)
                .fontWeight(.bold)

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
                    .symbolVariant(filtersActive ? .fill : .none)
                    .foregroundColor(filtersActive ? .green : .primary)
                    .font(.system(size: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Button { webViewStore.webView?.goBack() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
            }
            .disabled(!vm.canGoBack)

            Button { webViewStore.webView?.goForward() } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
            }
            .disabled(!vm.canGoForward)

            Button { webViewStore.webView?.reload() } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
            }

            ShareLink(item: vm.currentURL) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
        .padding(.bottom, 20)
        .background(Color(.systemBackground))
        .overlay(Divider(), alignment: .top)
    }
}

#Preview {
    RootView()
}
