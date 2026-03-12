# English Practice App - Current State

## Overview
A SwiftUI iOS app for practicing English sentences with Korean translations and text-to-speech.

## Architecture

### Models
- **`SentenceItem`** — `Identifiable` struct with `korean` and `english` String properties.
- **`SpeechManager`** — `@Observable` class wrapping `AVSpeechSynthesizer` for English TTS (en-US, rate 0.45).

### Views
- **`ContentView`** — Main screen with a `NavigationStack` and scrollable list of sentence cards.

### State
- `sentences: [SentenceItem]` — List of added sentence pairs.
- `expandedIDs: Set<UUID>` — Tracks which cards are expanded (showing English).
- `speechManager: SpeechManager` — Manages text-to-speech.

## UI Behavior
1. Tap **+** button to add a random Korean-English sentence pair from the pool.
2. Each card shows **Korean text** by default.
3. Tap a card to **expand** — reveals the English translation + a speaker button.
4. Tap the **speaker button** to hear the English sentence via TTS.
5. Tap an expanded card again to **collapse** it.

## Sentence Pool (15 sentences)

### "I am" statements
| Korean | English |
|--------|---------|
| 나는 학생입니다. | I am a student. |
| 나는 오늘 행복합니다. | I am happy today. |
| 나는 한국에서 왔습니다. | I am from Korea. |
| 나는 피곤합니다. | I am tired. |
| 나는 갈 준비가 되었습니다. | I am ready to go. |
| 나는 영어를 배우고 있습니다. | I am learning English. |
| 나는 배가 고픕니다. | I am hungry. |
| 나는 잘 들어주는 사람입니다. | I am a good listener. |

### "Am I" questions
| Korean | English |
|--------|---------|
| 내가 늦었나요? | Am I late? |
| 내가 이것을 제대로 하고 있나요? | Am I doing this right? |
| 내가 당신의 친구인가요? | Am I your friend? |
| 내가 너무 시끄러운가요? | Am I too loud? |
| 내가 맞는 길로 가고 있나요? | Am I on the right way? |
| 내가 일찍 왔나요? | Am I early? |
| 내가 너무 빨리 말하고 있나요? | Am I speaking too fast? |

## Files
- `ios/ios/ContentView.swift` — Main view + models + speech manager
- `ios/ios/iosApp.swift` — App entry point
- `ios/ios/Item.swift` — (unused SwiftData boilerplate)
