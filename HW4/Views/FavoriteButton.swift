import SwiftUI

struct FavoriteButton: View {
    var ticker: String
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @Binding var showingToast: Bool
    @Binding var toastMessage: String
    
    var body: some View {
        Button(action: toggleFavorite) {
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
    
    private var isFavorite: Bool {
        favoritesViewModel.favorites.contains { $0.id == ticker }
    }
    
    private func toggleFavorite() {
        if isFavorite {
            if let index = favoritesViewModel.favorites.firstIndex(where: { $0.id == ticker }) {
                favoritesViewModel.deleteFavorite(at: IndexSet(integer: index))
                toastMessage = "Removing \(ticker) from Favorites"
            }
        } else {
            favoritesViewModel.add(ticker: ticker)
            toastMessage = "Adding \(ticker) to Favorites"
        }
        showingToast = true
    }
}

struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        let balanceViewModel = BalanceViewModel()
        balanceViewModel.balance = 21747.26
        
        let portfolioViewModel = PortfolioViewModel()
        portfolioViewModel.loadDummyData()
        
        let favoritesViewModel = FavoritesViewModel()
        favoritesViewModel.loadDummyData()

        return StockInfoView(ticker: "NVDA")
            .environmentObject(balanceViewModel)
            .environmentObject(portfolioViewModel)
            .environmentObject(favoritesViewModel)
    }
}
