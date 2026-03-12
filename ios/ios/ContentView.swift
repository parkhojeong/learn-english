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
    let korean: String
    let english: String
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
    @State private var expandedIDs: Set<UUID> = []

    private let sentencePool: [(korean: String, english: String)] = [
        // I am — statements
        ("나는 학생입니다.", "I am a student."),
        ("나는 오늘 행복합니다.", "I am happy today."),
        ("나는 한국에서 왔습니다.", "I am from Korea."),
        ("나는 피곤합니다.", "I am tired."),
        ("나는 갈 준비가 되었습니다.", "I am ready to go."),
        ("나는 영어를 배우고 있습니다.", "I am learning English."),
        ("나는 배가 고픕니다.", "I am hungry."),
        ("나는 잘 들어주는 사람입니다.", "I am a good listener."),
        // Am I — questions
        ("내가 늦었나요?", "Am I late?"),
        ("내가 이것을 제대로 하고 있나요?", "Am I doing this right?"),
        ("내가 당신의 친구인가요?", "Am I your friend?"),
        ("내가 너무 시끄러운가요?", "Am I too loud?"),
        ("내가 맞는 길로 가고 있나요?", "Am I on the right way?"),
        ("내가 일찍 왔나요?", "Am I early?"),
        ("내가 너무 빨리 말하고 있나요?", "Am I speaking too fast?"),
    ]

    init() {
        _sentences = State(initialValue: sentencePool.map { pair in
            SentenceItem(korean: pair.korean, english: pair.english)
        })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sentences) { item in
                        let isExpanded = expandedIDs.contains(item.id)

                        VStack(alignment: .leading, spacing: 0) {
                            Text(item.korean)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if isExpanded {
                                Divider()
                                    .padding(.horizontal)

                                HStack {
                                    Text(item.english)
                                        .font(.body)
                                        .foregroundColor(.secondary)

                                    Spacer()

                                    Button {
                                        speechManager.speak(item.english)
                                    } label: {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .onTapGesture {
                            withAnimation {
                                if isExpanded {
                                    expandedIDs.remove(item.id)
                                } else {
                                    expandedIDs.insert(item.id)
                                }
                            }
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
        let usedEnglish = Set(sentences.map(\.english))
        let available = sentencePool.filter { !usedEnglish.contains($0.english) }
        if let pair = available.randomElement() {
            withAnimation {
                sentences.append(SentenceItem(korean: pair.korean, english: pair.english))
            }
        }
    }
}

#Preview {
    ContentView()
}
