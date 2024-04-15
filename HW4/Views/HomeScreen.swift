import SwiftUI

struct HomeScreen: View {
    var stockWorth: Double {
        portfolioViewModel.portfolioItems.reduce(0.0) { sum, item in
            sum + (Double(item.quantity) * (item.latestPrice ?? 0))
        }
    }
    
    @State private var searchText = ""
    @StateObject private var viewModel = SearchViewModel()
    
    @EnvironmentObject var balanceViewModel: BalanceViewModel
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    
    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    // Home View
                    
                    // Date
                    Section {
                        Text(Date.now, format: .dateTime.day().month(.wide).year())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.gray)
                            .padding(.all, 2)
                    }
                    
                    // Portfolio
                    let balance = balanceViewModel.balance ?? 99999
                    PortfolioView(netWorth: stockWorth + balance, balance: balance)
                    
                    // Favorites
                    // TODO: Delete
                    FavoritesView()
                    
                    // Footer
                    Section {
                        Link("Powered by Finnhub.io",
                              destination: URL(string: "https://finnhub.io")!)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    // Search Results
                    Section {
                        ForEach($viewModel.searchResults) { searchResult in
                            NavigationLink(
                                destination: StockInfoView(ticker: searchResult.symbol.wrappedValue),
                                label: {
                                    VStack(alignment: .leading) {
                                        Text("\(searchResult.symbol.wrappedValue)")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        Text("\(searchResult.description.wrappedValue)")
                                            .foregroundColor(Color.gray)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Stocks")
            .toolbar {
                EditButton()
            }
            // Piazza: https://piazza.com/class/lr3cfhx8jp718d/post/1119
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .onChange(of: searchText) {
                viewModel.searchStocks(query: searchText)
            }
        }
    }
}

func colorForChange(_ stockChange: Double) -> Color {
    if stockChange > 0 {
        return .green
    } else if stockChange < 0 {
        return .red
    } else {
        return .gray
    }
}

func symbolForChange(_ stockChange: Double) -> String {
    if stockChange > 0 {
        return "arrow.up.forward"
    } else if stockChange < 0 {
        return "arrow.down.forward"
    } else {
        return "minus"
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        let balanceViewModel = BalanceViewModel()
        balanceViewModel.balance = 21747.26
        
        let portfolioViewModel = PortfolioViewModel()
        portfolioViewModel.loadDummyData()
        
        let favoritesViewModel = FavoritesViewModel()
        favoritesViewModel.loadDummyData()

        return HomeScreen()
            .environmentObject(balanceViewModel)
            .environmentObject(portfolioViewModel)
            .environmentObject(favoritesViewModel)
    }
}

