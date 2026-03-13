//
//  Models.swift
//  ios
//
//  Created by hj on 3/12/26.
//

import SwiftUI
import AVFoundation
import SwiftData

struct SentenceItem: Identifiable {
    let id = UUID()
    let korean: String
    let english: String
}

struct GrammarStage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let sentencePool: [(korean: String, english: String)]
}

@Observable
class SpeechManager {
    private var synthesizer: AVSpeechSynthesizer?
    private let voiceIdentifierKey = "speechVoiceIdentifier"
    private let preferredVoiceIdentifiers = [
        "com.apple.ttsbundle.Alex-compact",
        "com.apple.ttsbundle.Samantha-compact",
    ]
    private let maleNameHints = [
        "Alex", "Daniel", "Tom", "Fred", "Aaron", "Arthur", "Bruce", "Eddy",
        "Evan", "Lee", "Mark", "Oliver", "Rishi", "Reed", "Ralph", "Yannick"
    ]

    func speak(_ text: String) {
        if synthesizer == nil {
            synthesizer = AVSpeechSynthesizer()
        }
        guard let synthesizer else { return }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = bestEnglishVoice()
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.0
        utterance.postUtteranceDelay = 0.0
        synthesizer.speak(utterance)
    }

    private func bestEnglishVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        if let storedIdentifier = UserDefaults.standard.string(forKey: voiceIdentifierKey),
           preferredVoiceIdentifiers.contains(storedIdentifier),
           let storedVoice = voices.first(where: { $0.identifier == storedIdentifier }) {
            return storedVoice
        }

        if let storedIdentifier = UserDefaults.standard.string(forKey: voiceIdentifierKey),
           storedIdentifier == "com.apple.ttsbundle.Alex-compact" {
            if let maleVoice = voices.first(where: { voice in
                voice.language.hasPrefix("en") && maleNameHints.contains(voice.name)
            }) {
                return maleVoice
            }
        }

        for identifier in preferredVoiceIdentifiers {
            if let voice = voices.first(where: { $0.identifier == identifier }) {
                return voice
            }
        }

        let enUSVoices = voices.filter { $0.language == "en-US" }
        if let best = enUSVoices.sorted(by: { $0.quality.rawValue > $1.quality.rawValue }).first {
            return best
        }

        if let anyEnglish = voices.first(where: { $0.language.hasPrefix("en") }) {
            return anyEnglish
        }

        return AVSpeechSynthesisVoice(language: "en-US")
    }
}

@Model
final class StageCompletion {
    var stageKey: String
    var isComplete: Bool

    init(stageKey: String, isComplete: Bool = false) {
        self.stageKey = stageKey
        self.isComplete = isComplete
    }
}
