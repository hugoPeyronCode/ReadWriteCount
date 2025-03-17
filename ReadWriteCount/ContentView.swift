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

  init() {
    self.currentProblem = MathGameViewModel.generateProblem()
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
    if userAnswer.count < 5 { // Limit input length
      userAnswer += "\(digit)"
    }
  }

  func deleteLastDigit() {
    if !userAnswer.isEmpty {
      userAnswer.removeLast()
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

struct ContentView: View {
  var gameViewModel = MathGameViewModel()
  var keyboardViewModel = KeyboardViewModel()

  init() {
    keyboardViewModel.onDigitPressed = { [weak gameViewModel] digit in
      gameViewModel?.appendDigit(digit)
    }

    keyboardViewModel.onDeletePressed = { [weak gameViewModel] in
      gameViewModel?.deleteLastDigit()
    }

    keyboardViewModel.onCheckPressed = { [weak gameViewModel] in
      gameViewModel?.checkAnswer()
    }
  }

  var answerBackgroundColor: Color {
    if let isCorrect = gameViewModel.isCorrect {
      return isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3)
    } else {
      return Color.gray.opacity(0.2)
    }
  }

  var body: some View {
    VStack {
      Spacer()

      // Math problem display
      HStack(spacing: 10) {
        Text(gameViewModel.currentProblem.displayText)
          .font(.system(size: 36, weight: .medium))
        
        ZStack {
          RoundedRectangle(cornerRadius: 10)
            .fill(answerBackgroundColor)
            .frame(width: max(80, CGFloat(gameViewModel.userAnswer.count * 20 + 40)), height: 60)

          Text(gameViewModel.userAnswer)
            .font(.system(size: 36, weight: .bold))
            .minimumScaleFactor(0.5)
        }
      }
      .padding(.horizontal)

      Spacer()

      // Keyboard
      MathKeyboard(viewModel: keyboardViewModel)
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
