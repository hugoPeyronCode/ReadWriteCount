//
//  ContentView.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 13/03/2025.
//


import SwiftUI
enum DifficultyLevel: Int, CaseIterable {
  case veryEasy = 0
  case easy = 1
  case medium = 2
  case hard = 3
  case veryHard = 4

  // Number range for each difficulty level
  var numberRange: ClosedRange<Int> {
    switch self {
    case .veryEasy: return 1...10
    case .easy: return 1...20
    case .medium: return 1...50
    case .hard: return 1...100
    case .veryHard: return 1...200
    }
  }

  // All operations are available from the start
  var availableOperations: [Sign] {
    switch self {
    case .veryEasy, .easy:
      return [.plus, .minus, .times, .divide]
    case .medium, .hard:
      return [.plus, .minus, .times, .divide]
    case .veryHard:
      return Sign.allCases // Including percentage at the hardest level
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
  var isCorrect: Bool? = nil
  var autoCheckEnabled: Bool = true
  var checkingInProgress: Bool = false

  // Difficulty system
  var currentDifficulty: DifficultyLevel = .veryEasy
  var consecutiveCorrectAnswers: Int = 0
  var consecutiveWrongAnswers: Int = 0

  // Confidence-building system
  var easyProblemsCounter: Int = 0
  var currentStreak: Int = 0
  var bestStreak: Int = 0

  // Constants
  let maxInputDigitsLength: Int = 5
  let requiredCorrectToLevelUp: Int = 4 // Increased to make level-up more meaningful
  let wrongAnswersToLevelDown: Int = 2
  let easyProblemsAfterFailure: Int = 2 // Number of easy problems to give after failure

  // Dependency injection
  var keyboardViewModel: KeyboardViewModel?

  // Score tracking
  var score: Int = 0
  var totalQuestionsAnswered: Int = 0
  var correctAnswers: Int = 0

  init() {
    self.currentProblem = MathGameViewModel.generateProblem(difficulty: .veryEasy, forceEasy: true)
  }

  private func updateKeyboardState() {
    keyboardViewModel?.canDelete = !userAnswer.isEmpty
    keyboardViewModel?.canValidate = !userAnswer.isEmpty
  }

  // Generate a problem based on the current difficulty level
  static func generateProblem(difficulty: DifficultyLevel, forceEasy: Bool = false) -> MathProblem {
    // Select a random operation from available ones for this difficulty
    let operations = difficulty.availableOperations
    let randomSign = operations.randomElement() ?? .plus

    var firstTerm = 0
    var secondTerm = 0

    // If we're forcing an easy problem or we're at the lowest difficulty
    if forceEasy || difficulty == .veryEasy {
      // Generate special easy problems that seem approachable
      switch randomSign {
      case .plus:
        // Make sums that equal 10, which are easy to recognize
        if Bool.random() {
          firstTerm = Int.random(in: 1...9)
          secondTerm = 10 - firstTerm
        } else {
          // Or just very simple addition
          firstTerm = Int.random(in: 1...5)
          secondTerm = Int.random(in: 1...5)
        }

      case .minus:
        // Easy subtraction with small numbers or resulting in 0/1/5
        if Bool.random() {
          // Subtraction to 0 or 1
          firstTerm = Int.random(in: 1...10)
          secondTerm = Bool.random() ? firstTerm : firstTerm - 1
        } else {
          // Small number minus smaller number
          firstTerm = Int.random(in: 6...10)
          secondTerm = Int.random(in: 1...5)
        }

      case .times:
        // Multiplication by 1, 2, 5, 10
        firstTerm = [1, 2, 5, 10].randomElement()!
        secondTerm = Int.random(in: 1...5)
        // Sometimes swap for variety
        if Bool.random() {
          swap(&firstTerm, &secondTerm)
        }

      case .divide:
        // Division resulting in 1, 2, or 5
        secondTerm = [1, 2, 5].randomElement()!
        firstTerm = secondTerm * Int.random(in: 1...5)

      case .percentage:
        // Very simple percentages (mainly 50% or 100%)
        secondTerm = [50, 100].randomElement()!
        firstTerm = [10, 20, 50, 100].randomElement()!
      }
    } else {
      // For normal problems, use strategies based on difficulty level
      let range = difficulty.numberRange

      // Special problem generation based on operation type
      switch randomSign {
      case .plus:
        // For addition, we can use various patterns
        if difficulty == .easy {
          // Sums to 10 or 20
          let target = [10, 20].randomElement()!
          firstTerm = Int.random(in: 1..<target)
          secondTerm = target - firstTerm
        } else if difficulty == .medium {
          // Adding to make round numbers (like 50 or 100)
          if Bool.random() {
            let target = [50, 100].randomElement()!
            firstTerm = target - Int.random(in: 1...20)
            secondTerm = target - firstTerm
          } else {
            // Adding small number to larger number
            firstTerm = Int.random(in: 20...40)
            secondTerm = Int.random(in: 1...10)
          }
        } else {
          // Hard: larger numbers but often with patterns
          if Bool.random() {
            // Round numbers that are easy to add
            firstTerm = Int.random(in: 1...9) * 10
            secondTerm = Int.random(in: 1...9) * 10
          } else {
            // General case
            firstTerm = Int.random(in: range)
            secondTerm = Int.random(in: range)
          }
        }

      case .minus:
        if difficulty == .easy {
          // Subtraction with small numbers
          firstTerm = Int.random(in: 5...15)
          secondTerm = Int.random(in: 1...5)
        } else if difficulty == .medium {
          // Allow negative results but keep them simple
          let allowNegative = Bool.random() && Bool.random() // 25% chance

          if allowNegative {
            secondTerm = Int.random(in: 10...20)
            firstTerm = Int.random(in: 1...9)
          } else {
            // Subtraction from round numbers (like 10, 20, 50)
            firstTerm = [10, 20, 50, 100].randomElement()!
            secondTerm = Int.random(in: 1...(firstTerm/2))
          }
        } else {
          // Hard: larger numbers but with patterns
          if Bool.random() {
            // Subtracting from 100
            firstTerm = 100
            secondTerm = Int.random(in: 1...99)
          } else {
            // General case
            firstTerm = Int.random(in: range)
            secondTerm = Int.random(in: 1...(firstTerm > 100 ? 50 : firstTerm/2))
          }
        }

        // Ensure no negative results until medium level
        if difficulty.rawValue < DifficultyLevel.medium.rawValue && firstTerm < secondTerm {
          swap(&firstTerm, &secondTerm)
        }

      case .times:
        if difficulty == .easy {
          // Easy multiplication by 1, 2, 5, 10
          let multiplier = [1, 2, 5, 10].randomElement()!
          let number = Int.random(in: 1...5)
          firstTerm = multiplier
          secondTerm = number
        } else if difficulty == .medium {
          // Medium: multiplications that seem harder but have patterns
          if Bool.random() {
            // Multiplication by 11
            firstTerm = 11
            secondTerm = Int.random(in: 2...9)
          } else if Bool.random() {
            // Doubles (same number × itself)
            firstTerm = Int.random(in: 2...9)
            secondTerm = firstTerm
          } else {
            // Multiplication by 5 or 10
            firstTerm = [5, 10].randomElement()!
            secondTerm = Int.random(in: 5...12)
          }
        } else {
          // Hard: larger multiplications but with patterns
          if Bool.random() {
            // Multiplying by 25 (quarter of 100)
            firstTerm = 25
            secondTerm = Int.random(in: 2...8)
          } else if Bool.random() {
            // Multiplication by 9 (has digit pattern)
            firstTerm = 9
            secondTerm = Int.random(in: 6...12)
          } else {
            // Multiplication with larger single digits
            firstTerm = Int.random(in: 6...9)
            secondTerm = Int.random(in: 6...12)
          }
        }

        // Sometimes swap for variety
        if Bool.random() {
          swap(&firstTerm, &secondTerm)
        }

      case .divide:
        // For division, always ensure clean integer results
        let divisors: [Int]

        if difficulty == .easy {
          // Easy division by 1, 2, 5
          divisors = [1, 2, 5]
        } else if difficulty == .medium {
          // Medium division by common factors
          divisors = [2, 3, 4, 5, 10]
        } else {
          // Hard division with larger factors
          divisors = [2, 4, 5, 8, 10, 20, 25]
        }

        secondTerm = divisors.randomElement()!

        // Make firstTerm a multiple of secondTerm for clean division
        let multiplierRange: ClosedRange<Int>
        switch difficulty {
        case .veryEasy, .easy: multiplierRange = 1...5
        case .medium: multiplierRange = 1...10
        case .hard: multiplierRange = 1...20
        case .veryHard: multiplierRange = 1...25
        }

        firstTerm = secondTerm * Int.random(in: multiplierRange)

      case .percentage:
        // Percentage calculations (only at very hard level normally)
        let percentages = [10, 20, 25, 50, 75, 100]
        secondTerm = percentages.randomElement()!

        let bases = [20, 50, 100, 200]
        firstTerm = bases.randomElement()!
      }
    }

    return MathProblem(
      firstTerm: firstTerm,
      secondTerm: secondTerm,
      sign: randomSign
    )
  }

  // Update difficulty based on player performance
  private func updateDifficulty() {
    // If we've answered enough correct to level up
    if consecutiveCorrectAnswers >= requiredCorrectToLevelUp {
      // Level up if not already at max
      if currentDifficulty.rawValue < DifficultyLevel.veryHard.rawValue {
        currentDifficulty = currentDifficulty.next
        consecutiveCorrectAnswers = 0
        consecutiveWrongAnswers = 0

        // Give a few easier problems at the new level to build confidence
        easyProblemsCounter = 2
      }
    }
    // If we've made too many mistakes
    else if consecutiveWrongAnswers >= wrongAnswersToLevelDown {
      // Level down if not already at min
      if currentDifficulty.rawValue > DifficultyLevel.veryEasy.rawValue {
        currentDifficulty = currentDifficulty.previous
        consecutiveCorrectAnswers = 0
        consecutiveWrongAnswers = 0

        // Give some easy problems to rebuild confidence
        easyProblemsCounter = easyProblemsAfterFailure
      } else {
        // If already at lowest level, still give some easy problems
        easyProblemsCounter = easyProblemsAfterFailure
      }
    }
    // If single wrong answer, give one easy problem to recover
    else if consecutiveWrongAnswers > 0 {
      easyProblemsCounter = 1
    }
  }

  // MARK: - Public Methods
  func appendDigit(_ digit: Int) {
    if userAnswer.count < maxInputDigitsLength {
      userAnswer += "\(digit)"
      updateKeyboardState()

      // Auto-check when digit count matches expected result length
      if autoCheckEnabled {
        let correctResultDigits = String(currentProblem.correctResult).count

        // If we've input the same number of digits as the correct answer
        if userAnswer.count == correctResultDigits {
          checkAnswer()
        }
      }
    }
  }

  func checkAnswer() {
    guard let userValue = Int(userAnswer) else { return }

    // Marquer que le processus de vérification est en cours
    checkingInProgress = true
    isCorrect = nil

    // Vérification avec délai pour créer le suspense
    Task { @MainActor in
      // Délai de vérification - moment de suspense (0.6 secondes)
      try? await Task.sleep(for: .seconds(0.6))

      // Vérifier si la réponse est correcte
      let correct = userValue == currentProblem.correctResult
      isCorrect = correct
      checkingInProgress = false

      // Mise à jour des statistiques et du score
      totalQuestionsAnswered += 1

      if correct {
        // Logique des réponses correctes
        score += scoringForCurrentDifficulty()
        correctAnswers += 1
        consecutiveCorrectAnswers += 1
        consecutiveWrongAnswers = 0

        // Mise à jour des séries
        currentStreak += 1
        bestStreak = max(bestStreak, currentStreak)
      } else {
        // Logique des réponses incorrectes
        consecutiveWrongAnswers += 1
        consecutiveCorrectAnswers = 0
        currentStreak = 0
      }

      // Mise à jour de la difficulté
      updateDifficulty()

      // Réinitialisation après un délai supplémentaire
      try? await Task.sleep(for: .seconds(1))

      if isCorrect == true {
        // Pour les réponses correctes, générer un nouveau problème
        generateNewProblem()
      } else {
        // Pour les réponses incorrectes, effacer l'entrée mais garder le même problème
        userAnswer = ""
        updateKeyboardState()
      }

      isCorrect = nil
    }
  }
  func deleteLastDigit() {
    if !userAnswer.isEmpty {
      userAnswer.removeLast()
      updateKeyboardState()
    }
  }

  func generateNewProblem() {
    // Check if we should generate an easier problem
    let forceEasy = easyProblemsCounter > 0
    if forceEasy {
      easyProblemsCounter -= 1
    }

    currentProblem = MathGameViewModel.generateProblem(
      difficulty: currentDifficulty,
      forceEasy: forceEasy
    )
    userAnswer = ""
    updateKeyboardState()
  }

  // Calculate score based on difficulty with streak bonus
  private func scoringForCurrentDifficulty() -> Int {
    // Base score by difficulty
    let baseScore: Int
    switch currentDifficulty {
    case .veryEasy: baseScore = 5
    case .easy: baseScore = 10
    case .medium: baseScore = 20
    case .hard: baseScore = 35
    case .veryHard: baseScore = 50
    }

    // Streak bonus (capped at 5 to prevent extreme differences)
    let streakBonus = min(currentStreak, 5) * 2

    return baseScore + streakBonus
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

  // Get an encouraging message based on streak/performance
  var encouragementMessage: String? {
    if currentStreak >= 5 {
      return "Impressive streak: \(currentStreak)!"
    } else if consecutiveCorrectAnswers >= requiredCorrectToLevelUp - 1 {
      return "Great progress! Keep going!"
    } else if consecutiveWrongAnswers > 0 {
      return "You've got this!"
    }
    return nil
  }
}
