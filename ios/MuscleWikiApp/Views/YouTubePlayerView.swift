import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    let embedURL: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: embedURL) else { return }
        // Only reload if the URL changed
        if webView.url?.absoluteString != embedURL {
            webView.load(URLRequest(url: url))
        }
    }
}

struct YouTubeSection: View {
    let embedURL: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Label("Full Tutorial", systemImage: "play.rectangle.fill")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isExpanded ? "Collapse tutorial video" : "Expand tutorial video")

            if isExpanded {
                YouTubePlayerView(embedURL: embedURL)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }
        }
    }
}
