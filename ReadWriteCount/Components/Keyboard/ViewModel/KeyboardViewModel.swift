//
//  KeyboardViewModel.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 15/03/2025.
//

import Foundation
import SwiftUI

@Observable
class KeyboardViewModel {
    var onDigitPressed: (Int) -> Void = { _ in }
    var onDeletePressed: () -> Void = {}
    var onCheckPressed: () -> Void = {}
}
