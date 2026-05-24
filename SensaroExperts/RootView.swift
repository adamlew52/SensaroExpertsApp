import SwiftUI
import Combine

struct RootView: View {
    @StateObject private var vm          = ForestryViewModel()
    @StateObject private var webViewStore = WebViewStore()
    @State private var showFilters  = false
    @State private var showSearch   = false

    // Debounce search so we don't reload on every keystroke
    @State private var searchCancellable: AnyCancellable?

    var filtersActive: Bool {
        vm.selectedState != .all || vm.sortOrder != .relevance
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // ── Web content ──
                WebViewContainer(
                    url: vm.currentURL,
                    store: webViewStore,
                    isLoading: $vm.isLoading,
                    canGoBack: $vm.canGoBack,
                    canGoForward: $vm.canGoForward
                )
                .ignoresSafeArea(edges: .bottom)

                // ── Loading bar ──
                if vm.isLoading {
                    ProgressView()
                        .progressViewStyle(.linear)
                        .tint(.green)
                        .transition(.opacity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "tree.fill")
                            .foregroundColor(.green)
                        Text("Sensaro Experts")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showSearch.toggle()
                            if !showSearch { vm.searchText = "" }
                        }
                    } label: {
                        Image(systemName: showSearch ? "xmark.circle.fill" : "magnifyingglass")
                    }
                    Button { showFilters = true } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolVariant(filtersActive ? .fill : .none)
                            .foregroundColor(filtersActive ? .green : .primary)
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button { webViewStore.webView?.goBack() } label: {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(!vm.canGoBack)
                    Spacer()
                    Button { webViewStore.webView?.goForward() } label: {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(!vm.canGoForward)
                    Spacer()
                    Button { webViewStore.webView?.reload() } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    Spacer()
                    ShareLink(item: vm.currentURL) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                if showSearch {
                    SearchBar(text: $vm.searchText)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterSheetView(viewModel: vm)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .tint(.green)
        // Reload when state/sort change
        .onChange(of: vm.selectedState) { _, _ in webViewStore.load(vm.currentURL) }
        .onChange(of: vm.sortOrder)     { _, _ in webViewStore.load(vm.currentURL) }
        // Debounce search input
        .onChange(of: vm.searchText) { _, _ in
            searchCancellable?.cancel()
            searchCancellable = Just(())
                .delay(for: .milliseconds(600), scheduler: RunLoop.main)
                .sink { webViewStore.load(vm.currentURL) }
        }
    }


}

#Preview {
    RootView()
}
