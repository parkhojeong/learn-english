//
//  ContentView.swift
//  ios
//
//  Created by hj on 3/12/26.
//

import SwiftUI
import AVFoundation

struct SentenceItem: Identifiable {
    let id = UUID()
    let text: String
}

@Observable
class SpeechManager {
    private var synthesizer: AVSpeechSynthesizer?

    func speak(_ text: String) {
        if synthesizer == nil {
            synthesizer = AVSpeechSynthesizer()
        }
        guard let synthesizer else { return }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.05
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1
        synthesizer.speak(utterance)
    }
}

struct ContentView: View {
    @State private var sentences: [SentenceItem] = []
    @State private var speechManager = SpeechManager()

    private let sentencePool: [String] = [
        // I am — statements
        "I am a student.",
        "I am happy today.",
        "I am from Korea.",
        "I am tired.",
        "I am ready to go.",
        "I am learning English.",
        "I am hungry.",
        "I am a good listener.",
        // Am I — questions
        "Am I late?",
        "Am I doing this right?",
        "Am I your friend?",
        "Am I too loud?",
        "Am I on the right way?",
        "Am I early?",
        "Am I speaking too fast?",
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sentences) { item in
                        ZStack(alignment: .topTrailing) {
                            Text(item.text)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)

                            Button {
                                speechManager.speak(item.text)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.blue)
                                    .padding(8)
                                    .background(Color(.systemBackground))
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .padding(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("English Practice")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        addSentence()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private func addSentence() {
        let usedTexts = Set(sentences.map(\.text))
        let available = sentencePool.filter { !usedTexts.contains($0) }
        if let sentence = available.randomElement() {
            withAnimation {
                sentences.append(SentenceItem(text: sentence))
            }
        }
    }
}

#Preview {
    ContentView()
}
