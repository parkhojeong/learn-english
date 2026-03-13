//
//  ContentView.swift
//  ios
//
//  Created by hj on 3/12/26.
//

import SwiftUI
import NaturalLanguage
import SwiftData
import UserNotifications

// MARK: - Models

struct SentencePair {
    let korean: String
    let english: String
}

// MARK: - Services

protocol SpeechSynthesizing {
    func speak(_ text: String)
}

protocol EnglishTagging {
    func tagged(_ text: String) -> AttributedString
}

protocol GrammarStageProviding {
    var stages: [GrammarStage] { get }
}

extension SpeechManager: SpeechSynthesizing {}

struct EnglishTagger: EnglishTagging {
    private let predicateWords: Set<String> = [
        // be
        "am", "is", "are", "was", "were", "'m", "'re", "'s",
        // do
        "do", "does", "did", "don't", "doesn't", "didn't",
        // have
        "have", "has", "had", "haven't", "hasn't", "hadn't",
        // modals
        "can", "can't", "cannot", "could", "couldn't",
        "will", "won't", "would", "wouldn't",
        "shall", "shan't", "should", "shouldn't",
        "may", "might", "must", "mustn't",
        // common contractions
        "'ll", "'d", "'ve",
    ]

    func tagged(_ text: String) -> AttributedString {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        tagger.setLanguage(.english, range: text.startIndex..<text.endIndex)

        struct WordInfo {
            let word: String
            let tag: NLTag?
            let tokenRange: Range<String.Index>
        }

        var words: [WordInfo] = []
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .lexicalClass,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, tokenRange in
            let word = String(text[tokenRange])
            words.append(WordInfo(word: word, tag: tag, tokenRange: tokenRange))
            return true
        }

        let predicateIndex: Int? = {
            if let idx = words.firstIndex(where: { $0.tag == .verb && predicateWords.contains($0.word.lowercased()) }) {
                return idx
            }
            return words.firstIndex(where: { $0.tag == .verb })
        }()

        var predicateIndices: Set<Int> = []
        if let start = predicateIndex {
            predicateIndices.insert(start)
            var next = start + 1
            while next < words.count && words[next].tag == .verb {
                predicateIndices.insert(next)
                next += 1
            }
            if start + 1 < words.count {
                let nextWord = words[start + 1].word.lowercased()
                if nextWord == "not" || nextWord == "n't" {
                    predicateIndices.insert(start + 1)
                    if start + 2 < words.count && words[start + 2].tag == .verb {
                        predicateIndices.insert(start + 2)
                    }
                }
            }
        }

        var subjectIndices: Set<Int> = []
        if let predStart = predicateIndex {
            let isQuestion = predStart == 0
            if isQuestion {
                let searchStart = (predicateIndices.max() ?? predStart) + 1
                for i in searchStart..<words.count {
                    let tag = words[i].tag
                    if tag == .noun || tag == .pronoun || tag == .determiner || tag == .adjective {
                        subjectIndices.insert(i)
                    } else {
                        break
                    }
                }
            } else {
                for i in 0..<predStart {
                    let tag = words[i].tag
                    if tag == .noun || tag == .pronoun || tag == .determiner || tag == .adjective {
                        subjectIndices.insert(i)
                    }
                }
            }
        }

        var result = AttributedString()
        var lastEnd = text.startIndex

        for (index, info) in words.enumerated() {
            if lastEnd < info.tokenRange.lowerBound {
                var gap = AttributedString(text[lastEnd..<info.tokenRange.lowerBound])
                gap.font = .body
                gap.foregroundColor = .secondary
                result.append(gap)
            }

            var token = AttributedString(text[info.tokenRange])
            if predicateIndices.contains(index) || subjectIndices.contains(index) {
                token.font = .body.bold()
                token.foregroundColor = .primary
            } else {
                token.font = .body
                token.foregroundColor = .secondary
            }
            result.append(token)
            lastEnd = info.tokenRange.upperBound
        }

        if lastEnd < text.endIndex {
            var trailing = AttributedString(text[lastEnd..<text.endIndex])
            trailing.font = .body
            trailing.foregroundColor = .secondary
            result.append(trailing)
        }

        return result
    }
}

struct DefaultGrammarStageStore: GrammarStageProviding {
    let stages: [GrammarStage] = grammarStages
}

final class StudyReminderScheduler {
    private let reminderIdentifier = "study.reminder.every.minute"
    private let title = "Study Reminder"
    private let body = "Time to start studying."

    func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default:
            return false
        }
    }

    func scheduleEveryMinute() async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        if pending.contains(where: { $0.identifier == reminderIdentifier }) {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: true)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        _ = try? await center.add(request)
    }

    func enableTestReminder() async {
        let granted = await requestAuthorizationIfNeeded()
        if granted {
            await scheduleEveryMinute()
        }
    }
}

// MARK: - View Models

@Observable
final class RandomPracticeViewModel {
    private let allSentences: [SentencePair]

    var currentSentence: SentencePair?
    var showEnglish = false
    private var history: [SentencePair] = []

    init(stageProvider: GrammarStageProviding) {
        self.allSentences = stageProvider.stages.flatMap { stage in
            stage.sentencePool.map { SentencePair(korean: $0.korean, english: $0.english) }
        }
    }

    func nextSentence() {
        if let currentSentence {
            history.append(currentSentence)
        }
        showEnglish = false
        currentSentence = allSentences.randomElement()
    }

    func revealEnglish() {
        showEnglish = true
    }

    func previousSentence() {
        guard let previous = history.popLast() else { return }
        showEnglish = false
        currentSentence = previous
    }

    var canGoBack: Bool {
        !history.isEmpty
    }
}

@Observable
final class SentencePracticeViewModel {
    let stage: GrammarStage

    var sentences: [SentenceItem]
    var expandedIDs: Set<UUID> = []

    init(stage: GrammarStage) {
        self.stage = stage
        self.sentences = stage.sentencePool.map { SentenceItem(korean: $0.korean, english: $0.english) }
    }

    func toggleExpansion(for itemID: UUID) {
        if expandedIDs.contains(itemID) {
            expandedIDs.remove(itemID)
        } else {
            expandedIDs.insert(itemID)
        }
    }

    func addSentence() {
        let usedEnglish = Set(sentences.map(\.english))
        let available = stage.sentencePool.filter { !usedEnglish.contains($0.english) }
        if let pair = available.randomElement() {
            sentences.append(SentenceItem(korean: pair.korean, english: pair.english))
        }
    }
}

// MARK: - Tab View

struct ContentView: View {
    private let stageProvider: GrammarStageProviding
    private let speechManager: SpeechSynthesizing
    private let tagger: EnglishTagging
    private let reminderScheduler = StudyReminderScheduler()

    init(
        stageProvider: GrammarStageProviding = DefaultGrammarStageStore(),
        speechManager: SpeechSynthesizing = SpeechManager(),
        tagger: EnglishTagging = EnglishTagger()
    ) {
        self.stageProvider = stageProvider
        self.speechManager = speechManager
        self.tagger = tagger
    }

    var body: some View {
        TabView {
            StageListView(
                stageProvider: stageProvider,
                speechManager: speechManager,
                tagger: tagger
            )
                .tabItem {
                    Label("Stages", systemImage: "list.number")
                }
            RandomPracticeView(
                viewModel: RandomPracticeViewModel(stageProvider: stageProvider),
                speechManager: speechManager,
                tagger: tagger
            )
                .tabItem {
                    Label("Random", systemImage: "shuffle")
                }
        }
        .task {
            await reminderScheduler.enableTestReminder()
        }
    }
}

// MARK: - Stage Selection View

struct StageListView: View {
    private let stageProvider: GrammarStageProviding
    private let speechManager: SpeechSynthesizing
    private let tagger: EnglishTagging
    @Environment(\.modelContext) private var modelContext
    @Query private var completions: [StageCompletion]

    init(
        stageProvider: GrammarStageProviding,
        speechManager: SpeechSynthesizing,
        tagger: EnglishTagging
    ) {
        self.stageProvider = stageProvider
        self.speechManager = speechManager
        self.tagger = tagger
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(stageProvider.stages.enumerated()), id: \.element.id) { index, stage in
                    HStack(spacing: 8) {
                        NavigationLink {
                            SentencePracticeView(
                                viewModel: SentencePracticeViewModel(stage: stage),
                                speechManager: speechManager,
                                tagger: tagger
                            )
                        } label: {
                            HStack(spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 28, alignment: .trailing)
                                Text(stage.subtitle)
                                    .font(.subheadline.weight(.medium))
                            }
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Toggle(isOn: completionBinding(for: stage)) {
                            Image(systemName: isComplete(stage: stage) ? "checkmark.circle.fill" : "checkmark.circle")
                                .foregroundStyle(isComplete(stage: stage) ? .green : .secondary)
                        }
                        .labelsHidden()
                        .toggleStyle(.button)
                        .tint(.green)
                        .accessibilityLabel(isComplete(stage: stage) ? "Stage complete" : "Mark stage complete")
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Stages")
        }
    }

    private func isComplete(stage: GrammarStage) -> Bool {
        completion(for: stage)?.isComplete == true
    }

    private func completion(for stage: GrammarStage) -> StageCompletion? {
        completions.first { $0.stageKey == stage.title }
    }

    private func completionBinding(for stage: GrammarStage) -> Binding<Bool> {
        Binding(
            get: { isComplete(stage: stage) },
            set: { isComplete in
                setCompletion(for: stage, isComplete: isComplete)
            }
        )
    }

    private func setCompletion(for stage: GrammarStage, isComplete: Bool) {
        if let completion = completion(for: stage) {
            completion.isComplete = isComplete
        } else if isComplete {
            let completion = StageCompletion(stageKey: stage.title, isComplete: true)
            modelContext.insert(completion)
        }
    }
}

// MARK: - Random Practice View

struct RandomPracticeView: View {
    @State private var viewModel: RandomPracticeViewModel
    private let speechManager: SpeechSynthesizing
    private let tagger: EnglishTagging

    init(
        viewModel: RandomPracticeViewModel = RandomPracticeViewModel(stageProvider: DefaultGrammarStageStore()),
        speechManager: SpeechSynthesizing = SpeechManager(),
        tagger: EnglishTagging = EnglishTagger()
    ) {
        _viewModel = State(initialValue: viewModel)
        self.speechManager = speechManager
        self.tagger = tagger
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                if let sentence = viewModel.currentSentence {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(sentence.korean)
                            .font(.title3.weight(.medium))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if viewModel.showEnglish {
                            Divider()
                                .padding(.horizontal)

                            HStack {
                                Text(tagger.tagged(sentence.english))

                                Spacer()

                                Button {
                                    speechManager.speak(sentence.english)
                                } label: {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding()
                        }
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        if !viewModel.showEnglish {
                            speechManager.speak(sentence.english)
                        }
                        withAnimation {
                            viewModel.revealEnglish()
                        }
                    }
                    .padding(.horizontal)

                    if !viewModel.showEnglish {
                        Text("Tap to reveal English")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        withAnimation {
                            viewModel.previousSentence()
                        }
                    } label: {
                        Label("Previous", systemImage: "arrow.uturn.left")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!viewModel.canGoBack)

                    Button {
                        withAnimation {
                            viewModel.nextSentence()
                        }
                    } label: {
                        Label("Next", systemImage: "shuffle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationTitle("Random Practice")
            .onAppear {
                if viewModel.currentSentence == nil {
                    viewModel.nextSentence()
                }
            }
        }
    }
}

// MARK: - Sentence Practice View

struct SentencePracticeView: View {
    @State private var viewModel: SentencePracticeViewModel
    private let speechManager: SpeechSynthesizing
    private let tagger: EnglishTagging

    init(
        viewModel: SentencePracticeViewModel,
        speechManager: SpeechSynthesizing,
        tagger: EnglishTagging
    ) {
        _viewModel = State(initialValue: viewModel)
        self.speechManager = speechManager
        self.tagger = tagger
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.sentences) { item in
                    let isExpanded = viewModel.expandedIDs.contains(item.id)

                    VStack(alignment: .leading, spacing: 0) {
                        Text(item.korean)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if isExpanded {
                            Divider()
                                .padding(.horizontal)

                            HStack {
                                Text(tagger.tagged(item.english))

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
                        if !isExpanded {
                            speechManager.speak(item.english)
                        }
                        withAnimation {
                            viewModel.toggleExpansion(for: item.id)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.stage.subtitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        viewModel.addSentence()
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: StageCompletion.self, inMemory: true)
}
