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
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }
}

struct ContentView: View {
    @State private var sentences: [SentenceItem] = []
    @State private var speechManager = SpeechManager()

    private let sentencePool: [String] = [
        "The quick brown fox jumps over the lazy dog.",
        "Learning English is a wonderful journey that opens doors to new cultures.",
        "Practice makes perfect when it comes to mastering a new language.",
        "Reading books every day can significantly improve your vocabulary.",
        "She decided to travel abroad to immerse herself in the English language.",
        "Communication is the key to building strong relationships with others.",
        "The weather forecast predicted heavy rain throughout the entire weekend.",
        "He completed his assignment before the deadline and submitted it early.",
        "Technology has transformed the way people learn and communicate globally.",
        "A balanced diet and regular exercise are essential for a healthy lifestyle.",
        "The museum exhibit showcased artwork from various historical periods.",
        "Critical thinking skills are developed through practice and reflection.",
        "The concert was absolutely amazing and exceeded everyone's expectations.",
        "Understanding grammar rules helps you construct sentences more accurately.",
        "Patience and consistency are the most important qualities for language learners.",
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
