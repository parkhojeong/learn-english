//
//  ContentView.swift
//  ios
//
//  Created by hj on 3/12/26.
//

import SwiftUI
import AVFoundation

// MARK: - Models

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

// MARK: - Stage Data

let grammarStages: [GrammarStage] = [
    GrammarStage(
        title: "Stage 1",
        subtitle: "I am — Statements",
        icon: "person.fill",
        sentencePool: [
            ("나는 학생입니다.", "I am a student."),
            ("나는 오늘 행복합니다.", "I am happy today."),
            ("나는 한국에서 왔습니다.", "I am from Korea."),
            ("나는 피곤합니다.", "I am tired."),
            ("나는 갈 준비가 되었습니다.", "I am ready to go."),
            ("나는 영어를 배우고 있습니다.", "I am learning English."),
            ("나는 배가 고픕니다.", "I am hungry."),
            ("나는 잘 들어주는 사람입니다.", "I am a good listener."),
        ]
    ),
    GrammarStage(
        title: "Stage 2",
        subtitle: "Am I — Questions",
        icon: "questionmark.circle.fill",
        sentencePool: [
            ("내가 늦었나요?", "Am I late?"),
            ("내가 이것을 제대로 하고 있나요?", "Am I doing this right?"),
            ("내가 당신의 친구인가요?", "Am I your friend?"),
            ("내가 너무 시끄러운가요?", "Am I too loud?"),
            ("내가 맞는 길로 가고 있나요?", "Am I on the right way?"),
            ("내가 일찍 왔나요?", "Am I early?"),
            ("내가 너무 빨리 말하고 있나요?", "Am I speaking too fast?"),
            ("내가 초대받은 건가요?", "Am I invited?"),
            ("내가 방해하고 있나요?", "Am I interrupting?"),
            ("내가 괜찮아 보이나요?", "Am I looking okay?"),
        ]
    ),
]

// MARK: - Stage Selection View

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(grammarStages) { stage in
                        NavigationLink(value: stage.id) {
                            HStack(spacing: 16) {
                                Image(systemName: stage.icon)
                                    .font(.system(size: 28))
                                    .foregroundStyle(.white)
                                    .frame(width: 56, height: 56)
                                    .background(.blue.gradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(stage.title)
                                        .font(.headline)
                                    Text(stage.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("English Practice")
            .navigationDestination(for: UUID.self) { stageID in
                if let stage = grammarStages.first(where: { $0.id == stageID }) {
                    SentencePracticeView(stage: stage)
                }
            }
        }
    }
}

// MARK: - Sentence Practice View

struct SentencePracticeView: View {
    let stage: GrammarStage

    @State private var sentences: [SentenceItem] = []
    @State private var speechManager = SpeechManager()
    @State private var expandedIDs: Set<UUID> = []

    var body: some View {
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
        .navigationTitle(stage.subtitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    addSentence()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            if sentences.isEmpty {
                sentences = stage.sentencePool.map {
                    SentenceItem(korean: $0.korean, english: $0.english)
                }
            }
        }
    }

    private func addSentence() {
        let usedEnglish = Set(sentences.map(\.english))
        let available = stage.sentencePool.filter { !usedEnglish.contains($0.english) }
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
