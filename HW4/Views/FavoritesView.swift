import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    
    var body: some View {
        Section(header: Text("Favorites")) {
            ForEach(favoritesViewModel.favorites) { favorite in
                NavigationLink(
                    destination: StockInfoView(ticker: favorite.id),
                    label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(favorite.id)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("$\(String(format: "%.2f", favorite.currentPrice))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            HStack {
                                Text(favorite.name)
                                    .foregroundStyle(.gray)
                                Spacer()
                                Text(Image(systemName: symbolForChange(favorite.change)))
                                    .foregroundStyle(colorForChange(favorite.change))
                                Text("$\(String(format: "%.2f", favorite.change))")
                                    .foregroundStyle(colorForChange(favorite.change))
                                Text("(\(String(format: "%.2f", favorite.changePercent))%)")
                                    .foregroundStyle(colorForChange(favorite.changePercent))
                            }
                        }
                    }
                )
            }
            .onMove(perform: favoritesViewModel.moveFavorite)
            .onDelete(perform: favoritesViewModel.deleteFavorite)
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        let favoritesViewModel = FavoritesViewModel()
        favoritesViewModel.loadDummyData()
        
        return NavigationStack {
            List {
                FavoritesView().environmentObject(favoritesViewModel)
            }
        }
    }
}
