import SwiftUI

struct PortfolioView: View {
    var netWorth: Double
    var balance: Double
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    
    var body: some View {
        Section(header: Text("Portfolio")) {
            HStack {
                // Net Worth
                VStack(alignment: .leading) {
                    Text("Net Worth")
                    Text("$\(String(format: "%.2f", netWorth))")
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Cash Balance
                VStack(alignment: .leading) {
                    Text("Cash Balance")
                    Text("$\(String(format: "%.2f", balance))")
                        .fontWeight(.bold)
                }
            }
            .font(.title3)
            
            ForEach(portfolioViewModel.portfolioItems) { item in
                NavigationLink (
                    destination: StockInfoView(ticker: item.id),
                    label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(item.id)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Spacer()
                                let marketValue = Double(item.quantity) * item.latestPrice
                                Text("$\(String(format: "%.2f", marketValue))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            HStack {
                                Text("\(item.quantity) shares")
                                    .foregroundStyle(.gray)
                                Spacer()
                                let marketValue = Double(item.quantity) * item.latestPrice
                                let change = marketValue - item.totalCost
                                let pChange = (change / item.totalCost) * 100
                                
                                Text(Image(systemName: symbolForChange(change)))
                                    .foregroundStyle(colorForChange(change))
                                Text("$\(String(format: "%.2f", change))")
                                    .foregroundStyle(colorForChange(change))
                                Text("(\(String(format: "%.2f", pChange))%)")
                                    .foregroundStyle(colorForChange(pChange))
                            }
                        }
                    }
                )
            }
            .onMove(perform: portfolioViewModel.movePortfolioItem)
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        let portfolioViewModel = PortfolioViewModel()
        portfolioViewModel.loadDummyData()
        
        return NavigationStack {
            List {
                PortfolioView(netWorth: 26000, balance: 25000)
                    .environmentObject(portfolioViewModel)
            }
        }
    }
}
