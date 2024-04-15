import SwiftUI

struct FavoriteButton: View {
    @State private var isFavorite = false
    var body: some View {
        Button(action: {
            isFavorite.toggle()
        }) {
            Image(systemName: "plus")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(isFavorite ? .white : .blue)
                .padding(4)
                .background(isFavorite ? Color.blue : Color(.systemBackground))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                )
        }
    }
}

#Preview {
    NavigationStack {
        StockInfoView(ticker: "AAPL")
    }
}
