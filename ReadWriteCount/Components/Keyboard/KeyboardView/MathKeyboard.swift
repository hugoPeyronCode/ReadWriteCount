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
    ZStack {
      RoundedRectangle(cornerRadius: 25)
        .frame(width: .infinity, height: 500)
        .foregroundStyle(.background)
        .ignoresSafeArea()

      VStack(spacing: 10) {
        HStack(spacing: 10) {
          NumberKey(number: 1, action: viewModel.onDigitPressed)
          NumberKey(number: 2, action: viewModel.onDigitPressed)
          NumberKey(number: 3, action: viewModel.onDigitPressed)
        }
        
        HStack(spacing: 10) {
          NumberKey(number: 4, action: viewModel.onDigitPressed)
          NumberKey(number: 5, action: viewModel.onDigitPressed)
          NumberKey(number: 6, action: viewModel.onDigitPressed)
        }
        
        HStack(spacing: 10) {
          NumberKey(number: 7, action: viewModel.onDigitPressed)
          NumberKey(number: 8, action: viewModel.onDigitPressed)
          NumberKey(number: 9, action: viewModel.onDigitPressed)
        }
        
        HStack(spacing: 10) {
          ActionKey(symbol: "checkmark", backgroundColor: .green, action: viewModel.onCheckPressed, isActive: $viewModel.canValidate)
          NumberKey(number: 0, action: viewModel.onDigitPressed)
          ActionKey(symbol: "delete.backward.fill", backgroundColor: .red, action: viewModel.onDeletePressed, isActive: $viewModel.canDelete)
        }
      }
    }
    .offset(y: 40)

  }
}
