# English Practice App - Current State

## Overview
A SwiftUI iOS app for practicing English grammar through Korean-to-English sentence translation, with text-to-speech and part-of-speech highlighting.

## Architecture

### Models
- **`SentenceItem`** — `Identifiable` struct with `korean` and `english` String properties.
- **`GrammarStage`** — `Identifiable` struct defining a grammar stage with `title`, `subtitle`, `icon`, and `sentencePool`.
- **`SpeechManager`** — `@Observable` class wrapping `AVSpeechSynthesizer` for English TTS (en-US, rate 0.45).

### Views
- **`ContentView`** — `TabView` with bottom tab navigation (Stages + Random).
- **`StageListView`** — Numbered list of 20 grammar stages, each navigating to a practice view.
- **`SentencePracticeView`** — Scrollable card list for a specific stage. Korean shown by default, tap to reveal English + TTS.
- **`RandomPracticeView`** — Shows one random sentence from all stages. Tap to reveal, shuffle button for next.

### Helper
- **`taggedEnglish(_:)`** — Uses `NLTagger` (NaturalLanguage framework) to parse English sentences and return an `AttributedString` with subject and predicate in **bold primary** and other words in secondary color. Handles both statement (S-V) and question (V-S) word order.

### State
- `sentences: [SentenceItem]` — List of sentence pairs for a stage.
- `expandedIDs: Set<UUID>` — Tracks which cards are expanded.
- `speechManager: SpeechManager` — Manages text-to-speech.
- `currentSentence` / `showEnglish` — Random practice state.

## UI Behavior

### Stages Tab
1. Numbered list of 20 grammar stages.
2. Tap a stage to open its sentence practice view.
3. Each card shows **Korean text** by default.
4. Tap a card to **reveal** the English translation with POS highlighting + auto TTS.
5. Tap the **speaker button** to replay TTS.
6. Tap an expanded card again to **collapse** it.

### Random Tab
1. Shows a random Korean sentence from all stages.
2. Tap the card to **reveal** English with POS highlighting + auto TTS.
3. Tap **Next** to shuffle to a new random sentence.

## Grammar Stages (20 stages, ~198 sentences)

| # | Pattern | Sentences |
|---|---------|-----------|
| 1 | I am — Statements | 8 |
| 2 | Am I — Questions | 10 |
| 3 | I want / I need | 10 |
| 4 | I can / I can't | 10 |
| 5 | I have / I don't have | 10 |
| 6 | I like / I don't like | 10 |
| 7 | I will / I won't | 10 |
| 8 | was / were — Past | 10 |
| 9 | should / should not | 10 |
| 10 | could / could not | 10 |
| 11 | would / would not | 10 |
| 12 | must / must not | 10 |
| 13 | do / does — Present | 10 |
| 14 | don't / doesn't | 10 |
| 15 | did — Past Simple | 10 |
| 16 | go / come / get | 10 |
| 17 | make / take / give | 10 |
| 18 | know / think / feel | 10 |
| 19 | see / look / watch | 10 |
| 20 | say / tell / ask | 10 |

## Files
- `ios/ios/ContentView.swift` — All views, models, POS tagging, speech manager
- `ios/ios/iosApp.swift` — App entry point
- `ios/ios/Item.swift` — (unused SwiftData boilerplate)
