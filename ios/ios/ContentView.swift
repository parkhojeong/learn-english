//
//  ContentView.swift
//  ios
//
//  Created by hj on 3/12/26.
//

import SwiftUI
import AVFoundation
import NaturalLanguage

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
    GrammarStage(
        title: "Stage 3",
        subtitle: "I want / I need",
        icon: "heart.fill",
        sentencePool: [
            ("나는 물 한 잔이 필요합니다.", "I need a glass of water."),
            ("나는 쉬고 싶습니다.", "I want to rest."),
            ("나는 도움이 필요합니다.", "I need some help."),
            ("나는 한국 음식이 먹고 싶습니다.", "I want to eat Korean food."),
            ("나는 더 많은 시간이 필요합니다.", "I need more time."),
            ("나는 새로운 것을 배우고 싶습니다.", "I want to learn something new."),
            ("나는 혼자 있고 싶습니다.", "I want to be alone."),
            ("나는 당신의 조언이 필요합니다.", "I need your advice."),
            ("나는 여행을 가고 싶습니다.", "I want to travel."),
            ("나는 더 연습이 필요합니다.", "I need more practice."),
        ]
    ),
    GrammarStage(
        title: "Stage 4",
        subtitle: "I can / I can't",
        icon: "hand.thumbsup.fill",
        sentencePool: [
            ("나는 영어를 말할 수 있습니다.", "I can speak English."),
            ("나는 수영을 할 수 없습니다.", "I can't swim."),
            ("나는 당신을 도와줄 수 있습니다.", "I can help you."),
            ("나는 그것을 이해할 수 없습니다.", "I can't understand that."),
            ("나는 기타를 칠 수 있습니다.", "I can play the guitar."),
            ("나는 그 차이를 구별할 수 없습니다.", "I can't tell the difference."),
            ("나는 운전을 할 수 있습니다.", "I can drive."),
            ("나는 매운 음식을 먹을 수 없습니다.", "I can't eat spicy food."),
            ("나는 내일 갈 수 있습니다.", "I can go tomorrow."),
            ("나는 그것을 약속할 수 없습니다.", "I can't promise that."),
        ]
    ),
    GrammarStage(
        title: "Stage 5",
        subtitle: "I have / I don't have",
        icon: "bag.fill",
        sentencePool: [
            ("나는 질문이 있습니다.", "I have a question."),
            ("나는 시간이 없습니다.", "I don't have time."),
            ("나는 형이 두 명 있습니다.", "I have two brothers."),
            ("나는 차가 없습니다.", "I don't have a car."),
            ("나는 좋은 생각이 있습니다.", "I have a good idea."),
            ("나는 경험이 없습니다.", "I don't have any experience."),
            ("나는 예약이 있습니다.", "I have a reservation."),
            ("나는 현금이 없습니다.", "I don't have cash."),
            ("나는 할 말이 있습니다.", "I have something to say."),
            ("나는 선택의 여지가 없습니다.", "I don't have a choice."),
        ]
    ),
    GrammarStage(
        title: "Stage 6",
        subtitle: "I like / I don't like",
        icon: "star.fill",
        sentencePool: [
            ("나는 커피를 좋아합니다.", "I like coffee."),
            ("나는 아침에 일찍 일어나는 것을 싫어합니다.", "I don't like waking up early."),
            ("나는 음악 듣는 것을 좋아합니다.", "I like listening to music."),
            ("나는 기다리는 것을 싫어합니다.", "I don't like waiting."),
            ("나는 비 오는 날을 좋아합니다.", "I like rainy days."),
            ("나는 혼잡한 곳을 싫어합니다.", "I don't like crowded places."),
            ("나는 요리하는 것을 좋아합니다.", "I like cooking."),
            ("나는 시험 보는 것을 싫어합니다.", "I don't like taking tests."),
            ("나는 산책하는 것을 좋아합니다.", "I like taking walks."),
            ("나는 거짓말을 싫어합니다.", "I don't like lies."),
        ]
    ),
    GrammarStage(
        title: "Stage 7",
        subtitle: "I will / I won't",
        icon: "arrow.right.circle.fill",
        sentencePool: [
            ("나는 최선을 다하겠습니다.", "I will do my best."),
            ("나는 포기하지 않겠습니다.", "I won't give up."),
            ("나는 내일 전화하겠습니다.", "I will call you tomorrow."),
            ("나는 늦지 않겠습니다.", "I won't be late."),
            ("나는 그것에 대해 생각해 보겠습니다.", "I will think about it."),
            ("나는 그것을 잊지 않겠습니다.", "I won't forget that."),
            ("나는 거기서 기다리겠습니다.", "I will wait there."),
            ("나는 다시는 그렇게 하지 않겠습니다.", "I won't do that again."),
            ("나는 당신을 도와주겠습니다.", "I will help you."),
            ("나는 아무에게도 말하지 않겠습니다.", "I won't tell anyone."),
        ]
    ),
    GrammarStage(
        title: "Stage 8",
        subtitle: "was / were — Past",
        icon: "clock.arrow.circlepath",
        sentencePool: [
            ("나는 어제 바빴습니다.", "I was busy yesterday."),
            ("그들은 파티에 있었습니다.", "They were at the party."),
            ("그녀는 정말 친절했습니다.", "She was really kind."),
            ("우리는 같은 학교에 있었습니다.", "We were in the same school."),
            ("날씨가 추웠습니다.", "It was cold."),
            ("그 아이들은 행복했습니다.", "The children were happy."),
            ("그는 좋은 선생님이었습니다.", "He was a good teacher."),
            ("너희들은 정말 용감했어.", "You were really brave."),
            ("그 영화는 재미있었습니다.", "It was an interesting movie."),
            ("그들은 오랜 친구였습니다.", "They were old friends."),
        ]
    ),
    GrammarStage(
        title: "Stage 9",
        subtitle: "should / should not",
        icon: "exclamationmark.triangle.fill",
        sentencePool: [
            ("너는 더 많이 자야 합니다.", "You should sleep more."),
            ("우리는 여기서 떠들면 안 됩니다.", "We should not talk here."),
            ("그는 의사에게 가야 합니다.", "He should see a doctor."),
            ("당신은 그녀에게 거짓말하면 안 됩니다.", "You should not lie to her."),
            ("나는 더 열심히 공부해야 합니다.", "I should study harder."),
            ("그들은 늦으면 안 됩니다.", "They should not be late."),
            ("우리는 서로 도와야 합니다.", "We should help each other."),
            ("너는 너무 많이 걱정하면 안 돼.", "You should not worry too much."),
            ("나는 물을 더 많이 마셔야 합니다.", "I should drink more water."),
            ("당신은 포기하면 안 됩니다.", "You should not give up."),
        ]
    ),
    GrammarStage(
        title: "Stage 10",
        subtitle: "could / could not",
        icon: "lightbulb.fill",
        sentencePool: [
            ("나는 그 답을 찾을 수 없었습니다.", "I could not find the answer."),
            ("우리는 함께 갈 수 있었습니다.", "We could go together."),
            ("그녀는 어렸을 때 피아노를 칠 수 있었습니다.", "She could play the piano when she was young."),
            ("나는 아무것도 볼 수 없었습니다.", "I could not see anything."),
            ("그는 세 가지 언어를 말할 수 있었습니다.", "He could speak three languages."),
            ("우리는 그를 믿을 수 없었습니다.", "We could not believe him."),
            ("당신은 나에게 물어볼 수 있었습니다.", "You could have asked me."),
            ("나는 잠을 잘 수 없었습니다.", "I could not sleep."),
            ("그들은 더 일찍 도착할 수 있었습니다.", "They could have arrived earlier."),
            ("나는 그 차이를 느낄 수 없었습니다.", "I could not feel the difference."),
        ]
    ),
    GrammarStage(
        title: "Stage 11",
        subtitle: "would / would not",
        icon: "bubble.left.fill",
        sentencePool: [
            ("나는 그렇게 하지 않겠습니다.", "I would not do that."),
            ("그녀는 항상 나를 도와주곤 했습니다.", "She would always help me."),
            ("당신이라면 어떻게 하시겠습니까?", "What would you do?"),
            ("나는 그것을 추천하지 않겠습니다.", "I would not recommend it."),
            ("그는 매일 공원에서 산책하곤 했습니다.", "He would walk in the park every day."),
            ("나라면 그 제안을 받아들이겠습니다.", "I would accept that offer."),
            ("그들은 거기에 가지 않겠다고 했습니다.", "They would not go there."),
            ("당신이라면 기다리시겠습니까?", "Would you wait?"),
            ("나는 차라리 집에 있겠습니다.", "I would rather stay home."),
            ("그녀는 절대 그런 말을 하지 않을 겁니다.", "She would never say that."),
        ]
    ),
    GrammarStage(
        title: "Stage 12",
        subtitle: "must / must not",
        icon: "lock.fill",
        sentencePool: [
            ("당신은 안전벨트를 매야 합니다.", "You must wear a seatbelt."),
            ("여기서 사진을 찍으면 안 됩니다.", "You must not take photos here."),
            ("우리는 규칙을 따라야 합니다.", "We must follow the rules."),
            ("이것을 아무에게도 말하면 안 됩니다.", "You must not tell anyone."),
            ("나는 이 일을 끝내야 합니다.", "I must finish this work."),
            ("여기서 뛰면 안 됩니다.", "You must not run here."),
            ("그는 매우 피곤한 게 틀림없습니다.", "He must be very tired."),
            ("도서관에서 큰 소리로 말하면 안 됩니다.", "You must not speak loudly in the library."),
            ("나는 더 노력해야 합니다.", "I must try harder."),
            ("시험 중에 전화를 사용하면 안 됩니다.", "You must not use your phone during the exam."),
        ]
    ),
    GrammarStage(
        title: "Stage 13",
        subtitle: "do / does — Present",
        icon: "checkmark.circle.fill",
        sentencePool: [
            ("나는 매일 운동합니다.", "I do exercise every day."),
            ("그녀는 아침에 요가를 합니다.", "She does yoga in the morning."),
            ("나는 이해합니다.", "I do understand."),
            ("그는 여기서 일합니다.", "He does work here."),
            ("우리는 최선을 다합니다.", "We do our best."),
            ("그것은 중요합니다.", "It does matter."),
            ("나는 당신을 믿습니다.", "I do believe you."),
            ("그녀는 요리를 잘 합니다.", "She does cook well."),
            ("나는 동의합니다.", "I do agree."),
            ("그는 정말 열심히 일합니다.", "He does work really hard."),
        ]
    ),
    GrammarStage(
        title: "Stage 14",
        subtitle: "don't / doesn't",
        icon: "xmark.circle.fill",
        sentencePool: [
            ("나는 커피를 마시지 않습니다.", "I don't drink coffee."),
            ("그녀는 고기를 먹지 않습니다.", "She doesn't eat meat."),
            ("나는 그것을 이해하지 못합니다.", "I don't understand that."),
            ("그는 여기에 살지 않습니다.", "He doesn't live here."),
            ("우리는 그것에 동의하지 않습니다.", "We don't agree with that."),
            ("날씨가 좋아 보이지 않습니다.", "It doesn't look good."),
            ("나는 그 사람을 모릅니다.", "I don't know that person."),
            ("그녀는 영어를 말하지 않습니다.", "She doesn't speak English."),
            ("나는 그것이 필요하지 않습니다.", "I don't need that."),
            ("그는 신경 쓰지 않습니다.", "He doesn't care."),
        ]
    ),
    GrammarStage(
        title: "Stage 15",
        subtitle: "did — Past Simple",
        icon: "clock.fill",
        sentencePool: [
            ("나는 어제 그것을 했습니다.", "I did it yesterday."),
            ("그녀는 숙제를 끝냈습니다.", "She did her homework."),
            ("우리는 좋은 일을 했습니다.", "We did a good job."),
            ("나는 어제 그를 보지 못했습니다.", "I didn't see him yesterday."),
            ("그들은 제시간에 도착하지 못했습니다.", "They didn't arrive on time."),
            ("너는 그에게 말했니?", "Did you tell him?"),
            ("그녀는 파티에 오지 않았습니다.", "She didn't come to the party."),
            ("너는 아침을 먹었니?", "Did you eat breakfast?"),
            ("나는 그것을 기대하지 못했습니다.", "I didn't expect that."),
            ("그는 무엇을 말했나요?", "What did he say?"),
        ]
    ),
    GrammarStage(
        title: "Stage 16",
        subtitle: "go / come / get",
        icon: "figure.walk",
        sentencePool: [
            ("나는 학교에 갑니다.", "I go to school."),
            ("여기로 오세요.", "Come here, please."),
            ("나는 버스를 탑니다.", "I get the bus."),
            ("우리 집에 가자.", "Let's go home."),
            ("그가 곧 올 겁니다.", "He will come soon."),
            ("나는 답을 알아냈습니다.", "I got the answer."),
            ("같이 가도 될까요?", "Can I go with you?"),
            ("언제 한국에 오셨나요?", "When did you come to Korea?"),
            ("나는 점점 나아지고 있습니다.", "I'm getting better."),
            ("어디 가세요?", "Where are you going?"),
        ]
    ),
    GrammarStage(
        title: "Stage 17",
        subtitle: "make / take / give",
        icon: "hand.raised.fill",
        sentencePool: [
            ("나는 결정을 내렸습니다.", "I made a decision."),
            ("사진 한 장 찍어 주세요.", "Please take a photo."),
            ("그것을 나에게 주세요.", "Give it to me."),
            ("그녀는 나를 웃게 만듭니다.", "She makes me laugh."),
            ("시간이 좀 걸릴 겁니다.", "It will take some time."),
            ("나에게 기회를 주세요.", "Give me a chance."),
            ("실수하지 마세요.", "Don't make a mistake."),
            ("택시를 타세요.", "Take a taxi."),
            ("나는 당신에게 조언을 해 줄게요.", "I'll give you some advice."),
            ("이것은 차이를 만듭니다.", "This makes a difference."),
        ]
    ),
    GrammarStage(
        title: "Stage 18",
        subtitle: "know / think / feel",
        icon: "brain.fill",
        sentencePool: [
            ("나는 알고 있습니다.", "I know."),
            ("나는 그것이 좋은 생각이라고 생각합니다.", "I think it's a good idea."),
            ("나는 기분이 좋습니다.", "I feel good."),
            ("나는 그 이유를 모르겠습니다.", "I don't know the reason."),
            ("당신은 어떻게 생각하세요?", "What do you think?"),
            ("나는 좀 불안합니다.", "I feel a little nervous."),
            ("그것은 누구나 알고 있습니다.", "Everyone knows that."),
            ("나는 우리가 할 수 있다고 생각합니다.", "I think we can do it."),
            ("나는 집이 그립습니다.", "I feel homesick."),
            ("나는 어디서 시작해야 할지 모르겠습니다.", "I don't know where to start."),
        ]
    ),
    GrammarStage(
        title: "Stage 19",
        subtitle: "see / look / watch",
        icon: "eye.fill",
        sentencePool: [
            ("나는 그를 어제 봤습니다.", "I saw him yesterday."),
            ("이것 좀 봐 주세요.", "Please look at this."),
            ("우리 영화를 보자.", "Let's watch a movie."),
            ("나는 차이를 모르겠습니다.", "I don't see the difference."),
            ("너 피곤해 보인다.", "You look tired."),
            ("나는 매일 뉴스를 봅니다.", "I watch the news every day."),
            ("알겠습니다.", "I see."),
            ("밖을 봐 보세요.", "Look outside."),
            ("아이들을 좀 봐 주세요.", "Please watch the children."),
            ("나는 그녀를 오랫동안 보지 못했습니다.", "I haven't seen her for a long time."),
        ]
    ),
    GrammarStage(
        title: "Stage 20",
        subtitle: "say / tell / ask",
        icon: "text.bubble.fill",
        sentencePool: [
            ("그가 뭐라고 말했나요?", "What did he say?"),
            ("나에게 사실을 말해 주세요.", "Tell me the truth."),
            ("질문 하나 해도 될까요?", "Can I ask a question?"),
            ("다시 한번 말해 주세요.", "Please say that again."),
            ("그녀는 나에게 비밀을 알려줬습니다.", "She told me a secret."),
            ("길을 물어봐야 합니다.", "I need to ask for directions."),
            ("안녕이라고 말하세요.", "Say goodbye."),
            ("나에게 어떻게 하는지 알려주세요.", "Tell me how to do it."),
            ("가격을 물어보세요.", "Ask about the price."),
            ("미안하다고 말하고 싶습니다.", "I want to say I'm sorry."),
        ]
    ),
]

// MARK: - POS-Tagged Text

// Known predicate words (auxiliaries, modals, common verbs used as predicates)
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

func taggedEnglish(_ text: String) -> AttributedString {
    let tagger = NLTagger(tagSchemes: [.lexicalClass])
    tagger.string = text
    tagger.setLanguage(.english, range: text.startIndex..<text.endIndex)

    // First pass: collect words with their tags to find the predicate
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

    // Find predicate: first verb that is a known predicate word,
    // or fall back to the first verb in the sentence
    let predicateIndex: Int? = {
        if let idx = words.firstIndex(where: { $0.tag == .verb && predicateWords.contains($0.word.lowercased()) }) {
            return idx
        }
        return words.firstIndex(where: { $0.tag == .verb })
    }()

    // Check if consecutive verbs form a verb phrase (e.g. "am learning", "don't like")
    var predicateIndices: Set<Int> = []
    if let start = predicateIndex {
        predicateIndices.insert(start)
        // Include consecutive verbs right after the predicate
        var next = start + 1
        while next < words.count && words[next].tag == .verb {
            predicateIndices.insert(next)
            next += 1
        }
        // Also include "not" or adverbs between predicate verbs
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

    // Find subject: in statements it's before the predicate,
    // in questions (predicate at index 0) it's right after the predicate
    var subjectIndices: Set<Int> = []
    if let predStart = predicateIndex {
        let isQuestion = predStart == 0
        if isQuestion {
            // Question: subject comes after the predicate (e.g. "Am I late?", "Did you eat?")
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
            // Statement: subject comes before the predicate
            for i in 0..<predStart {
                let tag = words[i].tag
                if tag == .noun || tag == .pronoun || tag == .determiner || tag == .adjective {
                    subjectIndices.insert(i)
                }
            }
        }
    }

    // Second pass: build attributed string
    var result = AttributedString()
    var lastEnd = text.startIndex

    for (index, info) in words.enumerated() {
        // Append gap (spaces, punctuation) before this word
        if lastEnd < info.tokenRange.lowerBound {
            var gap = AttributedString(text[lastEnd..<info.tokenRange.lowerBound])
            gap.font = .body
            gap.foregroundColor = .secondary
            result.append(gap)
        }

        var token = AttributedString(text[info.tokenRange])

        if predicateIndices.contains(index) || subjectIndices.contains(index) {
            // Subject & Predicate: bold
            token.font = .body.bold()
            token.foregroundColor = .primary
        } else {
            token.font = .body
            token.foregroundColor = .secondary
        }

        result.append(token)
        lastEnd = info.tokenRange.upperBound
    }

    // Append trailing punctuation/whitespace
    if lastEnd < text.endIndex {
        var trailing = AttributedString(text[lastEnd..<text.endIndex])
        trailing.font = .body
        trailing.foregroundColor = .secondary
        result.append(trailing)
    }

    return result
}

// MARK: - Tab View

struct ContentView: View {
    var body: some View {
        TabView {
            StageListView()
                .tabItem {
                    Label("Stages", systemImage: "list.number")
                }
            RandomPracticeView()
                .tabItem {
                    Label("Random", systemImage: "shuffle")
                }
        }
    }
}

// MARK: - Stage Selection View

struct StageListView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(grammarStages.enumerated()), id: \.element.id) { index, stage in
                    NavigationLink(value: stage.id) {
                        HStack(spacing: 8) {
                            Text("\(index + 1).")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 28, alignment: .trailing)
                            Text(stage.subtitle)
                                .font(.subheadline.weight(.medium))
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Stages")
            .navigationDestination(for: UUID.self) { stageID in
                if let stage = grammarStages.first(where: { $0.id == stageID }) {
                    SentencePracticeView(stage: stage)
                }
            }
        }
    }
}

// MARK: - Random Practice View

struct RandomPracticeView: View {
    @State private var currentSentence: (korean: String, english: String)?
    @State private var showEnglish = false
    @State private var speechManager = SpeechManager()

    private var allSentences: [(korean: String, english: String)] {
        grammarStages.flatMap { $0.sentencePool }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                if let sentence = currentSentence {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(sentence.korean)
                            .font(.title3.weight(.medium))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if showEnglish {
                            Divider()
                                .padding(.horizontal)

                            HStack {
                                Text(taggedEnglish(sentence.english))

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
                        withAnimation {
                            showEnglish = true
                        }
                    }
                    .padding(.horizontal)

                    if !showEnglish {
                        Text("Tap to reveal English")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                Button {
                    nextSentence()
                } label: {
                    Label("Next", systemImage: "shuffle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationTitle("Random Practice")
            .onAppear {
                if currentSentence == nil {
                    nextSentence()
                }
            }
        }
    }

    private func nextSentence() {
        withAnimation {
            showEnglish = false
            currentSentence = allSentences.randomElement()
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
                                Text(taggedEnglish(item.english))

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
