//
//  MathProblem.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 15/03/2025.
//


import SwiftUI

struct MathProblem {
  let firstTerm: Int
  let secondTerm: Int
  let sign: Sign

  var correctResult: Int {
    switch sign {
    case .plus:
      return firstTerm + secondTerm
    case .minus:
      return firstTerm - secondTerm
    case .times:
      return firstTerm * secondTerm
    case .divide:
      return secondTerm != 0 ? firstTerm / secondTerm : 0
    case .percentage:
      return (firstTerm * secondTerm) / 100
    }
  }

  var displayText: String {
    return "\(firstTerm) \(sign.rawValue) \(secondTerm) = "
  }
}
