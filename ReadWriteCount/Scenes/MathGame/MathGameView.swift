//
//  MathGameView.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 17/03/2025.
//

import SwiftUI

struct MathGameView: View {
  var gameViewModel = MathGameViewModel()
  var keyboardViewModel = KeyboardViewModel()

  // Add state for the blinking effect
  @State private var isUnderlineVisible = true

  // Add state for helper mode
  @State private var helperModeEnabled = true

  init() {
    // Connect the view models
    gameViewModel.keyboardViewModel = keyboardViewModel

    // Setup keyboard action handlers
    keyboardViewModel.onDigitPressed = { [weak gameViewModel] digit in
      gameViewModel?.appendDigit(digit)
    }

    keyboardViewModel.onDeletePressed = { [weak gameViewModel] in
      gameViewModel?.deleteLastDigit()
    }

    keyboardViewModel.onCheckPressed = { [weak gameViewModel] in
      gameViewModel?.checkAnswer()
    }

    // Initialize keyboard state
    keyboardViewModel.canDelete = false
    keyboardViewModel.canValidate = false
  }

  // Function to calculate correct underline width
  private func calculateUnderlineWidth() -> CGFloat {
    // With helper enabled, match expected answer width
    if helperModeEnabled {
      let correctAnswer = String(gameViewModel.currentProblem.correctResult)
      let digitCount = max(correctAnswer.count, gameViewModel.userAnswer.count)
      return CGFloat(digitCount * 30) // 30 pixels per digit is a good estimate
    } else {
      // Without helper, adjust to current input (minimum width for empty input)
      return max(60, CGFloat(gameViewModel.userAnswer.count * 30))
    }
  }

  var answerBackgroundColor: Color {
    if let isCorrect = gameViewModel.isCorrect {
      return isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3)
    } else {
      return Color.gray.opacity(0.15)
    }
  }

  let currentProblemNumbersSize: CGFloat = 50

  var body: some View {
    ZStack {
      Color.gray.opacity(0.2)
        .ignoresSafeArea()

      VStack {
        RoundedRectangle(cornerRadius: 15)
          .frame(height: 50)
          .foregroundStyle(.background)
          .padding(.horizontal)

        Spacer()

        // Math problem display
        HStack(spacing: 10) {
            Spacer()

            // Fixed position for the operation
            Text(gameViewModel.currentProblem.displayText)
            .font(.system(size: currentProblemNumbersSize, weight: .bold))
                .bold()

            // Answer field with left-to-right text growth
            ZStack(alignment: .leading) {
                // Blinking underline
                if isUnderlineVisible || gameViewModel.userAnswer.isEmpty == false {
                    Rectangle()
                        .frame(width: calculateUnderlineWidth(), height: 2)
                        .foregroundColor(.white)
                        .offset(y: 30)
                }

                Text(gameViewModel.userAnswer)
                    .font(.system(size: currentProblemNumbersSize, weight: .bold))
                    .lineLimit(1)
                    .frame(width: calculateUnderlineWidth(), alignment: .leading)
                    .foregroundColor(
                        gameViewModel.isCorrect == nil ? .white :
                        gameViewModel.isCorrect == true ? .green : .red
                    )
            }

            Spacer()
        }
        .minimumScaleFactor(0.7)
        .padding(.horizontal)
        .offset(y: 10)

        Spacer()

        MathKeyboard(viewModel: keyboardViewModel)
      }
    }
    .onAppear {
      // Start the blinking timer when view appears
      startBlinkingAnimation()
    }
  }

  // Function to create the blinking effect
  private func startBlinkingAnimation() {
    // Only blink while the answer is empty
    let timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
      if gameViewModel.userAnswer.isEmpty {
        withAnimation(.easeInOut(duration: 0.2)) {
          isUnderlineVisible.toggle()
        }
      } else {
        // Keep visible when user types
        isUnderlineVisible = true
      }
    }

    // Make sure the timer continues running
    RunLoop.current.add(timer, forMode: .common)
  }
}

#Preview {
  MathGameView()
}
