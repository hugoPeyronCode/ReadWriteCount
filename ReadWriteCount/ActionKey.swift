import SwiftUI

struct ActionKey: View {
    let symbol: String
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if symbol.count > 1 {
                Text(symbol)
                    .font(.title3)
                    .frame(width: 70, height: 70)
                    .background(backgroundColor.opacity(0.2))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                Image(systemName: symbol)
                    .font(.title)
                    .frame(width: 70, height: 70)
                    .background(backgroundColor.opacity(0.2))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
    }
}