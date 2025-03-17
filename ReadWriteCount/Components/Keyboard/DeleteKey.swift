//
//  DeleteKey.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 15/03/2025.
//


import SwiftUI

struct DeleteKey: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: "delete.left")
        .font(.title)
        .frame(width: 70, height: 70)
        .background(Color.red.opacity(0.2))
        .foregroundColor(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
  }
}