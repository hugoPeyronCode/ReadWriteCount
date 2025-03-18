//
//  MathGameView.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 17/03/2025.
//

import SwiftUI

struct MathGameView: View {
  @State var gameViewModel = MathGameViewModel()
  @State var keyboardViewModel = KeyboardViewModel()

  @State private var operationOpacity = 1.0
  @State private var operationScale = 1.0
  @State private var isShowingProblem = true
  @State private var isUnderlineVisible = true  // Add this back for the blinking effect

  let currentProblemNumbersSize: CGFloat = 50

  init() {
    setupViewModels()
  }

  var body: some View {
    ZStack {
      Color.gray.opacity(0.2).ignoresSafeArea()

      VStack {
        topProgressBar
        Spacer()
        mathProblemDisplay
        Spacer()
        MathKeyboard(viewModel: keyboardViewModel)
      }
    }
    .onAppear {
      configureInitialState()
    }
  }

  // MARK: - View Components

  private var topProgressBar : some View {
    ZStack {
      RoundedRectangle(cornerRadius: 15)
        .frame(height: 50)
        .foregroundStyle(Color.gray.opacity(0.2))

      Text(gameViewModel.progressInfo)
        .font(.system(size: 15, weight: .medium))
        .foregroundColor(.primary)
    }
    .padding(.horizontal)
  }

  private var mathProblemDisplay: some View {
    HStack {

      Spacer(minLength: 20)

      Text(gameViewModel.currentProblem.displayText)
        .font(.system(size: currentProblemNumbersSize, weight: .bold))
        .bold()
        .opacity(operationOpacity)
        .scaleEffect(operationScale)
        .fixedSize()

      answerField()

      Spacer(minLength: 20)
    }
    .frame(maxWidth: .infinity)
    .minimumScaleFactor(0.7)
    .padding(.horizontal)
  }

  @ViewBuilder
  private func answerField() -> some View {
    ZStack(alignment: .leading) {
      // Trait de soulignement
      if !gameViewModel.userAnswer.isEmpty || (gameViewModel.userAnswer.isEmpty && isUnderlineVisible) {
        RoundedRectangle(cornerRadius: 50)
          .frame(width: calculateUnderlineWidth(), height: 3)
          .foregroundColor(answerTextColor)
          .offset(y: 30)
      }

      Text(gameViewModel.userAnswer.isEmpty ? " " : gameViewModel.userAnswer)
        .font(.system(size: currentProblemNumbersSize, weight: .bold))
        .lineLimit(1)
        .foregroundColor(answerTextColor)
        .animation(.easeInOut(duration: 0.3), value: gameViewModel.isCorrect)
        .animation(.easeInOut(duration: 0.3), value: gameViewModel.checkingInProgress)
        .frame(width: calculateUnderlineWidth(), alignment: .leading)
    }
    .frame(width: calculateUnderlineWidth(), alignment: .leading)
    .fixedSize(horizontal: true, vertical: false)
    .opacity(operationOpacity)
    .scaleEffect(operationScale)
  }

  private var answerTextColor: Color {
    if gameViewModel.checkingInProgress {
      return .primary
    } else if let isCorrect = gameViewModel.isCorrect {
      return isCorrect ? .green : .red
    } else {

      return .primary
    }
  }

  // MARK: - Setup and Configuration

  private func setupViewModels() {
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

  private func configureInitialState() {
    // Start the blinking timer
    startBlinkingAnimation()

    // Setup initial animation state
    operationOpacity = 0
    operationScale = 0.8

    // Animate in the initial problem
    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
      operationOpacity = 1
      operationScale = 1
    }
  }

  // MARK: - Helper Methods

  private func calculateUnderlineWidth() -> CGFloat {
    // Garantir une largeur minimale même quand vide
    let correctAnswer = String(gameViewModel.currentProblem.correctResult)
    let digitCount = max(correctAnswer.count, gameViewModel.userAnswer.count)
    // Augmenter légèrement la largeur par chiffre pour plus d'espace
    return CGFloat(max(2, digitCount) * 30)
  }

  private func startBlinkingAnimation() {
    // Only blink while the answer is empty
    let timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
      if gameViewModel.userAnswer.isEmpty {
        withAnimation(.easeInOut(duration: 0.2)) {
          isUnderlineVisible.toggle()  // Toggle visibility for blinking effect
        }
      } else {
        // Keep visible when user types
        isUnderlineVisible = true
      }
    }
    RunLoop.current.add(timer, forMode: .common)
  }

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

      // Animate in the new problem with a more stable animation
      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        operationOpacity = 1
        operationScale = 1
        isShowingProblem = true
      }
    }
  }
}

#Preview {
  MathGameView()
}
