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
        .frame(width: 70, height: 70)
        .background(Color.blue.opacity(0.2))
        .foregroundColor(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
  }
}