import SwiftUI
import WebKit

struct WebViewContainer: UIViewRepresentable {
    let url: URL
    @ObservedObject var store: WebViewStore
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, canGoBack: $canGoBack, canGoForward: $canGoForward)
    }

    func makeUIView(context: Context) -> WKWebView {
        let wv = WKWebView(frame: .zero)
        wv.allowsBackForwardNavigationGestures = true
        wv.navigationDelegate = context.coordinator
        store.webView = wv
        wv.load(URLRequest(url: url))
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // URL changes handled via onChange in RootView → store.load()
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        @Binding var canGoBack: Bool
        @Binding var canGoForward: Bool

        init(isLoading: Binding<Bool>, canGoBack: Binding<Bool>, canGoForward: Binding<Bool>) {
            _isLoading    = isLoading
            _canGoBack    = canGoBack
            _canGoForward = canGoForward
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
            isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
            isLoading     = false
            canGoBack     = webView.canGoBack
            canGoForward  = webView.canGoForward
        }

        func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError _: Error) {
            isLoading = false
        }

        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation _: WKNavigation!,
                     withError _: Error) {
            isLoading = false
        }
    }
}
