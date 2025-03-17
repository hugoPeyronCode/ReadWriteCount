//
//  KeyView.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 15/03/2025.
//

import SwiftUI

struct ActionKey: View {
  let symbol: String
  let backgroundColor: Color
  let action: () -> Void
  @Binding var isActive: Bool

  var body: some View {
    Button(action: action) {
      Image(systemName: symbol)
    }
    .font(.largeTitle)
    .fontWeight(.black)
    .frame(width: 100, height: 100)
    .background(isActive ? backgroundColor.opacity(0.2) : backgroundColor.opacity(0.1))
    .foregroundStyle(isActive ? backgroundColor : backgroundColor.opacity(0.5))
    .clipShape(RoundedRectangle(cornerRadius: isActive ? 25 : 150))
    .animation(.snappy(duration: 0.6), value: isActive)
  }
}
