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
    .background(isActive ? backgroundColor.opacity(0.2) : .gray.opacity(0.2))
    .foregroundStyle(isActive ? backgroundColor : .gray.opacity(0.2))
    .clipShape(RoundedRectangle(cornerRadius: 25))
  }
}
