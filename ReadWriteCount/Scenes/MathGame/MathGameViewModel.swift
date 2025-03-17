//
//  MathGameViewModel.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 13/03/2025.
//

import SwiftUI

// Define difficulty levels for the game
enum DifficultyLevel: Int, CaseIterable {
    case veryEasy = 0
    case easy = 1
    case medium = 2
    case hard = 3
    case veryHard = 4

    // More human-friendly number ranges for each difficulty level
    var numberRange: ClosedRange<Int> {
        switch self {
        case .veryEasy: return 1...5      // Simple single digits
        case .easy: return 3...10         // Easy single digits
        case .medium: return 5...15       // Manageable numbers
        case .hard: return 10...25        // Challenging but reasonable
        case .veryHard: return 12...30    // Difficult but still human-doable
        }
    }

    // Available operations for each difficulty level
    var availableOperations: [Sign] {
        switch self {
        case .veryEasy: return [.plus]
        case .easy: return [.plus, .minus]
        case .medium: return [.plus, .minus, .times]
        case .hard: return [.plus, .minus, .times, .divide]
        case .veryHard: return Sign.allCases
        }
    }

    // Next difficulty level
    var next: DifficultyLevel {
        let nextRawValue = self.rawValue + 1
        return DifficultyLevel(rawValue: nextRawValue) ?? .veryHard
    }

    // Previous difficulty level
    var previous: DifficultyLevel {
        let prevRawValue = self.rawValue - 1
        return DifficultyLevel(rawValue: prevRawValue) ?? .veryEasy
    }
}

@Observable
class MathGameViewModel {
    // Game state
    var userAnswer: String = ""
    var currentProblem: MathProblem
    var previousSign: Sign? = nil
    var previousFirstTerm: Int? = nil
    var previousSecondTerm: Int? = nil
    var isCorrect: Bool? = nil

    // Difficulty system
    var currentDifficulty: DifficultyLevel = .veryEasy
    var consecutiveCorrectAnswers: Int = 0
    var consecutiveWrongAnswers: Int = 0

    // Constants
    let maxInputDigitsLength: Int = 5
    let requiredCorrectToLevelUp: Int = 5  // Increased to make progression more gradual
    let wrongAnswersToLevelDown: Int = 3   // Increased to be more forgiving

    // Timing constant - reduced for faster gameplay
    let answerDelay: TimeInterval = 0.5    // Shorter delay for faster pace

    // Dependency injection
    var keyboardViewModel: KeyboardViewModel?

    // Score tracking
    var score: Int = 0
    var totalQuestionsAnswered: Int = 0
    var correctAnswers: Int = 0

    init() {
        self.currentProblem = MathGameViewModel.generateProblem(difficulty: .veryEasy,
                                                                previousSign: nil,
                                                                previousFirstTerm: nil,
                                                                previousSecondTerm: nil)
    }

    private func updateKeyboardState() {
        keyboardViewModel?.canDelete = !userAnswer.isEmpty
        keyboardViewModel?.canValidate = !userAnswer.isEmpty
    }

    // Generate a problem based on the current difficulty level
    static func generateProblem(difficulty: DifficultyLevel,
                               previousSign: Sign?,
                               previousFirstTerm: Int?,
                               previousSecondTerm: Int?) -> MathProblem {
        // Select a random operation from available ones for this difficulty
        let operations = difficulty.availableOperations
        var randomSign: Sign

        // Allow the same operation to appear twice in a row
        randomSign = operations.randomElement() ?? .plus

        let range = difficulty.numberRange

        // Generate appropriate numbers based on operation
        var firstTerm = Int.random(in: range)
        var secondTerm = Int.random(in: range)

        // Special handling for certain operations
        switch randomSign {
        case .minus:
            // For subtraction, ensure first term >= second term to avoid negative results
            if firstTerm < secondTerm {
                swap(&firstTerm, &secondTerm)
            }
        case .times:
            // For multiplication, make one number smaller for easier mental math
            if difficulty == .medium {
                secondTerm = min(secondTerm, 10)
            } else if difficulty == .hard {
                secondTerm = min(secondTerm, 12)
            } else if difficulty == .veryHard {
                // Cap one of the numbers to make it more reasonable
                if Bool.random() {
                    firstTerm = min(firstTerm, 15)
                } else {
                    secondTerm = min(secondTerm, 15)
                }
            }
        case .divide:
            // For division, ensure we have clean division with no remainder
            // And make it more human-friendly (smaller numbers)
            secondTerm = [2, 3, 4, 5, 6, 8, 10].randomElement() ?? 2
            // Then, make firstTerm a multiple of secondTerm
            let multiplier = max(1, Int.random(in: 1...min(10, range.upperBound / secondTerm)))
            firstTerm = secondTerm * multiplier
        case .percentage:
            // Make percentage calculations straightforward with common values
            secondTerm = [5, 10, 20, 25, 50].randomElement() ?? 10
            // Use more friendly numbers for percentage base
            firstTerm = [20, 40, 50, 60, 80, 100, 200].randomElement() ?? 100
        default:
            break
        }

        return MathProblem(
            firstTerm: firstTerm,
            secondTerm: secondTerm,
            sign: randomSign
        )
    }

    // Update difficulty based on player performance
    private func updateDifficulty() {
        if consecutiveCorrectAnswers >= requiredCorrectToLevelUp {
            // Level up difficulty if not already at max
            if currentDifficulty.rawValue < DifficultyLevel.veryHard.rawValue {
                currentDifficulty = currentDifficulty.next
                consecutiveCorrectAnswers = 0
                consecutiveWrongAnswers = 0
            }
        } else if consecutiveWrongAnswers >= wrongAnswersToLevelDown {
            // Level down difficulty if not already at min
            if currentDifficulty.rawValue > DifficultyLevel.veryEasy.rawValue {
                currentDifficulty = currentDifficulty.previous
                consecutiveCorrectAnswers = 0
                consecutiveWrongAnswers = 0
            }
        }
    }

    // MARK: - Public Methods

    func appendDigit(_ digit: Int) {
        if userAnswer.count < maxInputDigitsLength {
            userAnswer += "\(digit)"
            updateKeyboardState()
        }
    }

    func deleteLastDigit() {
        if !userAnswer.isEmpty {
            userAnswer.removeLast()
            updateKeyboardState()
        }
    }

    func checkAnswer() {
        guard let userValue = Int(userAnswer) else { return }
        let correct = userValue == currentProblem.correctResult
        isCorrect = correct

        // Update score and statistics
        totalQuestionsAnswered += 1

        if correct {
            // Correct answer logic
            score += scoringForCurrentDifficulty()
            correctAnswers += 1
            consecutiveCorrectAnswers += 1
            consecutiveWrongAnswers = 0
        } else {
            // Wrong answer logic
            consecutiveWrongAnswers += 1
            consecutiveCorrectAnswers = 0
        }

        // Update difficulty based on performance
        updateDifficulty()

        // Save current problem details to potentially allow repeats
        previousSign = currentProblem.sign
        previousFirstTerm = currentProblem.firstTerm
        previousSecondTerm = currentProblem.secondTerm

        // Reset after a delay
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(answerDelay))
            if isCorrect == true {
                generateNewProblem()
            }
            isCorrect = nil
        }
    }

    func generateNewProblem() {
        currentProblem = MathGameViewModel.generateProblem(
            difficulty: currentDifficulty,
            previousSign: previousSign,
            previousFirstTerm: previousFirstTerm,
            previousSecondTerm: previousSecondTerm
        )
        userAnswer = ""
        updateKeyboardState()
    }

    // Calculate score based on difficulty
    private func scoringForCurrentDifficulty() -> Int {
        switch currentDifficulty {
        case .veryEasy: return 5
        case .easy: return 10
        case .medium: return 20
        case .hard: return 35
        case .veryHard: return 50
        }
    }

    // Return current progress info for display
    var progressInfo: String {
        return "Level: \(difficultyName) | Score: \(score) | Correct: \(correctAnswers)/\(totalQuestionsAnswered)"
    }

    // User-friendly difficulty name
    var difficultyName: String {
        switch currentDifficulty {
        case .veryEasy: return "Beginner"
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .veryHard: return "Expert"
        }
    }
}
