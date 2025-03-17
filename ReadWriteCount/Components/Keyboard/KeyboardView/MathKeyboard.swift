//
//  MathKeyboard.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 15/03/2025.
//


import SwiftUI

struct MathKeyboard: View {
  @State var viewModel: KeyboardViewModel

  var body: some View {
    VStack(spacing: 15) {
      HStack(spacing: 15) {
        NumberKey(number: 7, action: viewModel.onDigitPressed)
        NumberKey(number: 8, action: viewModel.onDigitPressed)
        NumberKey(number: 9, action: viewModel.onDigitPressed)
      }

      HStack(spacing: 15) {
        NumberKey(number: 4, action: viewModel.onDigitPressed)
        NumberKey(number: 5, action: viewModel.onDigitPressed)
        NumberKey(number: 6, action: viewModel.onDigitPressed)
      }

      HStack(spacing: 15) {
        NumberKey(number: 1, action: viewModel.onDigitPressed)
        NumberKey(number: 2, action: viewModel.onDigitPressed)
        NumberKey(number: 3, action: viewModel.onDigitPressed)
      }

      HStack(spacing: 15) {
        ActionKey(symbol: "checkmark", backgroundColor: .green, action: viewModel.onCheckPressed, isActive: $viewModel.canValidate)
        NumberKey(number: 0, action: viewModel.onDigitPressed)
        ActionKey(symbol: "delete.backward.fill", backgroundColor: .red, action: viewModel.onDeletePressed, isActive: $viewModel.canDelete)
      }
    }
    .padding(.bottom)
  }
}
