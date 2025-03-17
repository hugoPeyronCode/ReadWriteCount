//
//  KeyView.swift
//  ReadWriteCount
//
//  Created by Hugo Peyron on 15/03/2025.
//

import SwiftUI

enum KeyShape {
  case rounded(radius: CGFloat)
  case circle
  case square
}

struct Key<Content: View>: View {
  // Content to display
  let content: Content

  // Visual properties
  let backgroundColor: Color
  let shape: KeyShape
  let width: CGFloat
  let height: CGFloat

  // Action
  let action: () -> Void

  init(
    backgroundColor: Color = Color.blue.opacity(0.2),
    shape: KeyShape = .rounded(radius: 15),
    width: CGFloat = 70,
    height: CGFloat = 70,
    action: @escaping () -> Void,
    @ViewBuilder content: () -> Content
  ) {
    self.backgroundColor = backgroundColor
    self.shape = shape
    self.width = width
    self.height = height
    self.action = action
    self.content = content()
  }

  var body: some View {
    Button(action: action) {
      content
        .frame(width: width, height: height)
        .background(backgroundColor)
        .foregroundColor(.primary)
        .clipShape(shapeView)
    }
  }

  @ViewBuilder
  private var shapeView: some Shape {
    switch shape {
    case .rounded(let radius):
      RoundedRectangle(cornerRadius: radius)
    case .circle:
      Circle()
    case .square:
      Rectangle()
    }
  }
}

// Extensions for common key types
extension Key where Content == Text {
  init(
    number: Int,
    backgroundColor: Color = Color.blue.opacity(0.2),
    shape: KeyShape = .rounded(radius: 15),
    width: CGFloat = 70,
    height: CGFloat = 70,
    action: @escaping (Int) -> Void
  ) {
    self.init(
      backgroundColor: backgroundColor,
      shape: shape,
      width: width,
      height: height,
      action: { action(number) }
    ) {
      Text("\(number)")
        .font(.title)
    }
  }
}

extension Key where Content == Image {
  init(
    systemName: String,
    backgroundColor: Color = Color.blue.opacity(0.2),
    shape: KeyShape = .rounded(radius: 15),
    width: CGFloat = 70,
    height: CGFloat = 70,
    action: @escaping () -> Void
  ) {
    self.init(
      backgroundColor: backgroundColor,
      shape: shape,
      width: width,
      height: height,
      action: action
    ) {
      Image(systemName: systemName)
        .font(systemName.count > 1 ? .title3 : .title)
    }
  }
}

// Specialized Key for text content without number parameter
extension Key where Content == Text {
  init(
    text: String,
    backgroundColor: Color = Color.blue.opacity(0.2),
    shape: KeyShape = .rounded(radius: 15),
    width: CGFloat = 70,
    height: CGFloat = 70,
    action: @escaping () -> Void
  ) {
    self.init(
      backgroundColor: backgroundColor,
      shape: shape,
      width: width,
      height: height,
      action: action
    ) {
      Text(text)
        .font(.title)
    }
  }
}

// MARK: - MathKeyboard View
struct MathKeyboard: View {
  let onDigitPressed: (Int) -> Void
  let onDeletePressed: () -> Void
  let onCheckPressed: () -> Void

  var body: some View {
    VStack(spacing: 15) {
      HStack(spacing: 15) {
        Key(number: 7) { onDigitPressed($0) }
        Key(number: 8) { onDigitPressed($0) }
        Key(number: 9) { onDigitPressed($0) }
      }

      HStack(spacing: 15) {
        Key(number: 4) { onDigitPressed($0) }
        Key(number: 5) { onDigitPressed($0) }
        Key(number: 6) { onDigitPressed($0) }
      }

      HStack(spacing: 15) {
        Key(number: 1) { onDigitPressed($0) }
        Key(number: 2) { onDigitPressed($0) }
        Key(number: 3) { onDigitPressed($0) }
      }

      HStack(spacing: 15) {
        Key(text: "Check", backgroundColor: .green.opacity(0.2)) {
          onCheckPressed()
        }
        Key(number: 0) { onDigitPressed($0) }
        Key(systemName: "delete.left", backgroundColor: .red.opacity(0.2)) {
          onDeletePressed()
        }
      }
    }
    .padding(.bottom)
  }
}

// MARK: - Preview
struct Key_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 20) {
      HStack(spacing: 10) {
        Key(number: 1, shape: .rounded(radius: 15)) { _ in }
        Key(number: 2, shape: .circle) { _ in }
        Key(number: 3, shape: .square) { _ in }
      }

      HStack(spacing: 10) {
        Key(systemName: "delete.left", backgroundColor: .red.opacity(0.2)) {}
        Key(text: "Check", backgroundColor: .green.opacity(0.2), shape: .circle) {}
      }

      Key(backgroundColor: .purple.opacity(0.3), shape: .rounded(radius: 10)) {
        print("Custom content")
      } content: {
        VStack {
          Image(systemName: "star.fill")
          Text("Custom")
        }
      }

      MathKeyboard(
        onDigitPressed: { digit in print("Pressed \(digit)") },
        onDeletePressed: { print("Delete pressed") },
        onCheckPressed: { print("Check pressed") }
      )
    }
    .padding()
  }
}
