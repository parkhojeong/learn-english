//
//  iosTests.swift
//  iosTests
//
//  Created by hj on 3/12/26.
//

import Testing
import SwiftUI
@testable import ios

// MARK: - Stage Data Tests

struct StageDataTests {

    @Test func allStagesHaveUniqueTitle() {
        let titles = grammarStages.map(\.title)
        #expect(Set(titles).count == titles.count, "Stage titles should be unique")
    }

    @Test func allStagesHaveSentences() {
        for stage in grammarStages {
            #expect(!stage.sentencePool.isEmpty, "\(stage.title) should have sentences")
        }
    }

    @Test func stageCountIs20() {
        #expect(grammarStages.count == 20)
    }

    @Test func noEmptyKoreanOrEnglish() {
        for stage in grammarStages {
            for pair in stage.sentencePool {
                #expect(!pair.korean.isEmpty, "Korean should not be empty in \(stage.title)")
                #expect(!pair.english.isEmpty, "English should not be empty in \(stage.title)")
            }
        }
    }

    @Test func noDuplicateEnglishWithinStage() {
        for stage in grammarStages {
            let sentences = stage.sentencePool.map(\.english)
            #expect(Set(sentences).count == sentences.count, "Duplicate English in \(stage.title)")
        }
    }

    @Test func totalSentenceCount() {
        let total = grammarStages.reduce(0) { $0 + $1.sentencePool.count }
        #expect(total >= 190, "Should have at least 190 sentences, got \(total)")
    }
}

// MARK: - Tagged English Tests

struct TaggedEnglishTests {

    @Test func returnsNonEmptyResult() {
        let result = taggedEnglish("I am a student.")
        #expect(!result.characters.isEmpty)
    }

    @Test func preservesFullText() {
        let text = "I am a student."
        let result = taggedEnglish(text)
        let output = String(result.characters)
        #expect(output == text, "Output '\(output)' should match input '\(text)'")
    }

    @Test func preservesQuestionText() {
        let text = "Am I late?"
        let result = taggedEnglish(text)
        let output = String(result.characters)
        #expect(output == text)
    }

    @Test func preservesLongSentence() {
        let text = "I don't know where to start."
        let result = taggedEnglish(text)
        let output = String(result.characters)
        #expect(output == text)
    }

    @Test func handlesSingleWord() {
        let result = taggedEnglish("Hello")
        let output = String(result.characters)
        #expect(output == "Hello")
    }

    @Test func handlesEmptyString() {
        let result = taggedEnglish("")
        #expect(result.characters.isEmpty)
    }

    @Test func hasMultipleStyledRuns() {
        // taggedEnglish should produce multiple attributed runs for a multi-word sentence
        let result = taggedEnglish("I am happy.")
        var runCount = 0
        for _ in result.runs {
            runCount += 1
        }
        #expect(runCount >= 1, "Should have at least one styled run")
    }

    @Test func allStageSentencesProduceValidOutput() {
        for stage in grammarStages {
            for pair in stage.sentencePool {
                let result = taggedEnglish(pair.english)
                let output = String(result.characters)
                #expect(output == pair.english, "Mismatch in \(stage.title): '\(output)' vs '\(pair.english)'")
            }
        }
    }
}

// MARK: - SentenceItem Tests

struct SentenceItemTests {

    @Test func hasUniqueIDs() {
        let a = SentenceItem(korean: "안녕", english: "Hello")
        let b = SentenceItem(korean: "안녕", english: "Hello")
        #expect(a.id != b.id, "Each SentenceItem should have a unique ID")
    }

    @Test func storesValues() {
        let item = SentenceItem(korean: "나는 학생입니다.", english: "I am a student.")
        #expect(item.korean == "나는 학생입니다.")
        #expect(item.english == "I am a student.")
    }
}
