import SwiftUI

enum TradeAction {
    case buy, sell
}

struct StockPortfolioView: View {
    var ticker: String
    var stockInfo: StockInfo
    
    @EnvironmentObject var balanceViewModel: BalanceViewModel
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    
    @State private var showTradeSheet = false
    @State private var numberOfSharesToTrade: String = ""
    @State private var tradeAction: TradeAction = .buy
    
    var tickerIndex: Int? {
        portfolioViewModel.portfolioItems.firstIndex(where: { $0.id == ticker })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Portfolio").font(.title2)
            HStack {
                if let index = tickerIndex {
                    VStack(alignment: .leading) {
                        let sharesOwned = portfolioViewModel.portfolioItems[index].quantity
                        let totalCost = portfolioViewModel.portfolioItems[index].totalCost
                        let avgCost = totalCost / Double(sharesOwned)
                        let marketValue = portfolioViewModel.portfolioItems[index].latestPrice * Double(sharesOwned)
                        let change = marketValue - totalCost
                        
                        HStack {
                            Text("Shares Owned:").fontWeight(.bold)
                            Text("\(sharesOwned)")
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Text("Avg. Cost / Share:").fontWeight(.bold)
                            Text("$\(String(format: "%.2f", avgCost))")
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Text("Total Cost:").fontWeight(.bold)
                            Text("$\(String(format: "%.2f", totalCost))")
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Text("Change:").fontWeight(.bold)
                            Text("$\(String(format: "%.2f", change))").foregroundStyle(colorForChange(change))
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Text("Market Value:").fontWeight(.bold)
                            Text("$\(String(format: "%.2f", marketValue))").foregroundStyle(colorForChange(change))
                        }
                    }
                    .font(.footnote)
                }
                else {
                    VStack(alignment: .leading) {
                        Text("You have 0 shares of \(ticker).")
                        Text("Start trading!")
                    }
                    .font(.footnote)
                }
                Spacer()
                Button(action: {
                    showTradeSheet = true
                }) {
                    Text("Trade")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: 110)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(40)
                }
                .sheet(isPresented: $showTradeSheet) {
                    TradeSheetView(showTradeSheet: $showTradeSheet, numberOfSharesToTrade: $numberOfSharesToTrade, tradeAction: $tradeAction, ticker: ticker, stockInfo: stockInfo)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TradeSheetView: View {
    @Binding var showTradeSheet: Bool
    @Binding var numberOfSharesToTrade: String
    @Binding var tradeAction: TradeAction
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @EnvironmentObject var balanceViewModel: BalanceViewModel
    
    var ticker: String
    var stockInfo: StockInfo
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var showSuccess = false
    @State private var successfulTradeAction: TradeAction?
    @State private var successfulTradeShares: Int = 0

    var body: some View {
        NavigationView {
            VStack {
                Text("Trade \(stockInfo.name) shares")
                    .font(.headline)
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline) {
                    TextField("0", text: $numberOfSharesToTrade)
                        .keyboardType(.numberPad)
                        .padding()
                        .font(.system(size: 90))
                        .fontWeight(.light)
                    Text("Shares")
                        .font(.title)
                }
                
                // Display the calculated result based on the number of shares entered
                HStack {
                    Spacer()
                    let numShares = Int(numberOfSharesToTrade) ?? 0
                    let pricePerShare = stockInfo.currentPrice
                    Text("x $\(String(format: "%.2f", pricePerShare))/share = $\(String(format: "%.2f", Double(numShares) * pricePerShare))")
                }
                
                Spacer()
                
                Text("$\(String(format: "%.2f", balanceViewModel.balance)) available to buy \(ticker)")
                    .font(.callout)
                    .foregroundStyle(Color.gray)
                    .padding()
                
                HStack {
                    Button("Buy") {
                        tradeAction = .buy
                        executeTrade()
                    }
                    .buttonStyle(GreenButtonStyle())
                    .padding(.leading)
                    
                    Button("Sell") {
                        tradeAction = .sell
                        executeTrade()
                    }
                    .buttonStyle(GreenButtonStyle())
                    .padding(.trailing)
                }
            }
            .padding()
            .navigationBarItems(trailing: Button(action: {
                showTradeSheet = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .overlay(
            successOverlay
        )
    }
    
    var successOverlay: some View {
        Group {
            if showSuccess {
                SuccessView(action: successfulTradeAction!, numberOfShares: successfulTradeShares, ticker: ticker) {
                    self.showTradeSheet = false
                }
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: showSuccess)
    }
    
    func executeTrade() {
        guard let numShares = Int(numberOfSharesToTrade), numShares > 0 else {
            alertMessage = "Please enter a valid amount"
            showAlert = true
            return
        }
        
        switch tradeAction {
        case .buy:
            if balanceViewModel.balance >= (Double(numShares) * stockInfo.currentPrice) {
                portfolioViewModel.buyStock(ticker: ticker, quantity: numShares, totalCost: Double(numShares) * stockInfo.currentPrice)
                balanceViewModel.balance -= Double(numShares) * stockInfo.currentPrice
                successfulTradeAction = .buy
                successfulTradeShares = numShares
                showSuccess = true
            } else {
                alertMessage = "Not enough money to buy"
                showAlert = true
                return
            }
        case .sell:
            if let sharesOwned = portfolioViewModel.portfolioItems.first(where: { $0.id == ticker })?.quantity, sharesOwned >= numShares {
                balanceViewModel.balance += Double(numShares) * stockInfo.currentPrice
                portfolioViewModel.sellStock(ticker: ticker, quantity: numShares, totalRevenue: Double(numShares) * stockInfo.currentPrice)
                successfulTradeAction = .sell
                successfulTradeShares = numShares
                showSuccess = true
            } else {
                alertMessage = "Not enough shares to sell"
                showAlert = true
                return
            }
        }
        
        numberOfSharesToTrade = ""
    }
}

// Button styles for buy and sell
struct GreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .cornerRadius(40)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SuccessView: View {
    var action: TradeAction
    var numberOfShares: Int
    var ticker: String
    var onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
            
            Text("You have successfully \(action == .buy ? "bought" : "sold") \(numberOfShares) share\(numberOfShares > 1 ? "s" : "") of \(ticker)")
                .font(.body)
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
            
            Button(action: {
                onDismiss()
            }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(40)
            }
            .padding()
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
        .edgesIgnoringSafeArea(.all)
    }
}


struct StockPortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        let balanceViewModel = BalanceViewModel()
        balanceViewModel.balance = 21747.26
        
        let portfolioViewModel = PortfolioViewModel()
        portfolioViewModel.loadDummyData()
        
        let favoritesViewModel = FavoritesViewModel()
        favoritesViewModel.loadDummyData()
        
        let stockInfo = StockInfo(ticker: "AAPL", name: "Apple Inc", exchange: "NASDAQ NMS - GLOBAL MARKET", logo: "https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AAPL.png", currentPrice: 172.57, change: 1.20, changePercent: 0.70, timestamp: 1712779201, marketClose: true)

        return StockPortfolioView(ticker: "AMD", stockInfo: stockInfo)
            .environmentObject(balanceViewModel)
            .environmentObject(portfolioViewModel)
            .environmentObject(favoritesViewModel)
    }
}

