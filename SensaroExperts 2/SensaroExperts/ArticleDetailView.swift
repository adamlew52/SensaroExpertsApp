import SwiftUI
import WebKit

// Opens the real article URL in a WKWebView
struct ArticleDetailView: View {
    let article: Article
    @State private var isLoading = true
    @State private var webView = WKWebView()

    var body: some View {
        ZStack(alignment: .top) {
            WebReader(url: article.articleURL, webView: webView, isLoading: $isLoading)
                .ignoresSafeArea(edges: .bottom)
            if isLoading {
                ProgressView()
                    .progressViewStyle(.linear)
                    .tint(.green)
            }
        }
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let url = article.articleURL {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

// MARK: - Minimal WKWebView wrapper (detail only, no nav bar needed)

struct WebReader: UIViewRepresentable {
    let url: URL?
    let webView: WKWebView
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator { Coordinator(isLoading: $isLoading) }

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        if let url {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        init(isLoading: Binding<Bool>) { _isLoading = isLoading }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) { isLoading = true }
        func webView(_ webView: WKWebView, didFinish _: WKNavigation!) { isLoading = false }
        func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError _: Error) { isLoading = false }
    }
}
