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

  // Animation states
  @State private var operationOpacity = 1.0
  @State private var operationScale = 1.0
  @State private var isShowingProblem = true

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

  // Function to animate problem transition
  func animateNewProblem() {
    withAnimation(.easeOut(duration: 0.2)) {
      operationOpacity = 0
      operationScale = 0.8
      isShowingProblem = false
    }

    // Quick delay then show new problem
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
      // Generate new problem
      gameViewModel.generateNewProblem()

      // Animate in the new problem
      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        operationOpacity = 1
        operationScale = 1
        isShowingProblem = true
      }
    }
  }

  var body: some View {
    ZStack {
      Color.gray.opacity(0.2)
        .ignoresSafeArea()

      VStack {
        // Top bar with difficulty and score
        ZStack {
          RoundedRectangle(cornerRadius: 15)
            .frame(height: 50)
            .foregroundStyle(Color.gray.opacity(0.2))

          Text(gameViewModel.progressInfo)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
        }
        .padding(.horizontal)

        Spacer()

        // Math problem display
        HStack(spacing: 10) {
          Spacer()

          // Fixed position for the operation with animation
          Text(gameViewModel.currentProblem.displayText)
            .font(.system(size: currentProblemNumbersSize, weight: .bold))
            .bold()
            .opacity(operationOpacity)
            .scaleEffect(operationScale)

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
          .opacity(operationOpacity)
          .scaleEffect(operationScale)

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

      // Generate initial problem with animation
      operationOpacity = 0
      operationScale = 0.8

      withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
        operationOpacity = 1
        operationScale = 1
      }
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
