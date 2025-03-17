//
//  KeyboardViewModel.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 15/03/2025.
//

import SwiftUI

@Observable
class KeyboardViewModel {
  var canDelete: Bool = false
  var canValidate: Bool = false
  var onDigitPressed: (Int) -> Void = { _ in }
  var onDeletePressed: () -> Void = {}
  var onCheckPressed: () -> Void = {}
}
