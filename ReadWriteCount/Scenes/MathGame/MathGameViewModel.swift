//
//  ContentView.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 13/03/2025.
//

import SwiftUI

@Observable
class MathGameViewModel {
  var userAnswer: String = ""
  var currentProblem: MathProblem
  var isCorrect: Bool? = nil

  var keyboardViewModel: KeyboardViewModel?

  // Constants Hardcoded
  let maxInputDigitsLength: Int = 5

  init() {
    self.currentProblem = MathGameViewModel.generateProblem()
  }

  private func updateKeyboardState() {
    keyboardViewModel?.canDelete = !userAnswer.isEmpty
    keyboardViewModel?.canValidate = !userAnswer.isEmpty
  }

  static func generateProblem() -> MathProblem {
    let randomSign = Sign.allCases.randomElement() ?? .plus
    return MathProblem(
      firstTerm: Int.random(in: 1...20),
      secondTerm: Int.random(in: 1...20),
      sign: randomSign
    )
  }

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
    isCorrect = userValue == currentProblem.correctResult

    // Reset after a delay
    Task { @MainActor in
      try? await Task.sleep(for: .seconds(1))
      if isCorrect == true {
        generateNewProblem()
      }
      isCorrect = nil
    }
  }

  func generateNewProblem() {
    currentProblem = MathGameViewModel.generateProblem()
    userAnswer = ""
  }
}
