import Foundation
import AVFoundation

class VoiceService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var playbackProgress: TimeInterval = 0

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var playbackTimer: Timer?
    private var currentRecordingURL: URL?

    override init() {
        super.init()
    }

    // MARK: - Audio Session

    private func configureAudioSession(for category: AVAudioSession.Category) throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(category, mode: .default, options: [])
        try session.setActive(true)
    }

    // MARK: - Recording

    func startRecording() throws -> URL {
        try configureAudioSession(for: .record)

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "voice_\(UUID().uuidString).m4a"
        let fileURL = documentsPath.appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.record()

        currentRecordingURL = fileURL
        isRecording = true
        recordingDuration = 0

        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.recordingDuration += 0.1
        }

        return fileURL
    }

    func stopRecording() -> URL? {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false

        recordingTimer?.invalidate()
        recordingTimer = nil

        return currentRecordingURL
    }

    // MARK: - Playback

    func playRecording(from url: URL) throws {
        try configureAudioSession(for: .playback)

        stopPlayback()

        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
        audioPlayer?.play()
        isPlaying = true

        playbackProgress = 0
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, let player = self.audioPlayer else { return }
            self.playbackProgress = player.currentTime
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false

        playbackTimer?.invalidate()
        playbackTimer = nil
        playbackProgress = 0
    }

    func togglePlayback(from url: URL) throws {
        if isPlaying {
            stopPlayback()
        } else {
            try playRecording(from: url)
        }
    }

    // MARK: - Helpers

    func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    static func recordingDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

extension VoiceService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.playbackTimer?.invalidate()
            self?.playbackTimer = nil
            self?.playbackProgress = 0
        }
    }
}
