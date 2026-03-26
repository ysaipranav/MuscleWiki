import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let urls: [String]
    @State private var selectedIndex = 0
    @State private var player: AVPlayer?

    var body: some View {
        VStack(spacing: 0) {
            if let player {
                VideoPlayer(player: player)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemFill))
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .overlay {
                        ProgressView()
                    }
            }

            if urls.count > 1 {
                Picker("Camera Angle", selection: $selectedIndex) {
                    Text("Front").tag(0)
                    if urls.count > 1 { Text("Side").tag(1) }
                }
                .pickerStyle(.segmented)
                .padding(.top, 8)
                .onChange(of: selectedIndex) { _, newIndex in
                    loadVideo(at: newIndex)
                }
            }
        }
        .onAppear { loadVideo(at: selectedIndex) }
        .onDisappear { player?.pause() }
        .accessibilityLabel("Exercise demonstration video")
    }

    private func loadVideo(at index: Int) {
        guard index < urls.count else { return }
        // Strip the fragment (#t=0.1) before creating the URL for AVPlayer
        let rawURL = urls[index].components(separatedBy: "#").first ?? urls[index]
        guard let url = URL(string: rawURL) else { return }

        let newPlayer = AVPlayer(url: url)
        newPlayer.isMuted = true

        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newPlayer.currentItem,
            queue: .main
        ) { _ in
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }

        player = newPlayer
        newPlayer.play()
    }
}
