//
//  NumberKey.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 15/03/2025.
//


import SwiftUI

struct NumberKey: View {
  let number: Int
  let action: (Int) -> Void

  var body: some View {
    Button(action: {
      action(number)
    }) {
      Text("\(number)")
        .font(.title)
        .fontWeight(.bold)
        .fontDesign(.rounded)
        .frame(width: 100, height: 100)
        .background(.gray.opacity(0.2))
        .foregroundColor(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 40))

    }
  }
}
