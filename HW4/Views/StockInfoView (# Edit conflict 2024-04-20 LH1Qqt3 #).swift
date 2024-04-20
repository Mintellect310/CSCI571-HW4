import SwiftUI
import Alamofire
import SwiftyJSON
import Kingfisher

struct StockInfoView: View {
    @StateObject private var stockInfoViewModel = StockInfoViewModel()
    @StateObject private var summaryViewModel = SummaryViewModel()
    @StateObject private var insightsViewModel = InsightsViewModel()
    @StateObject private var historicalChartViewModel = HistoricalChartViewModel()
    @StateObject private var hourlyChartViewModel = HourlyChartViewModel()
    @StateObject private var newsViewModel = NewsViewModel()
    
    @EnvironmentObject var balanceViewModel: BalanceViewModel
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    
    var ticker: String
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if stockInfoViewModel.isLoading || summaryViewModel.isLoading || insightsViewModel.isLoading || historicalChartViewModel.isLoading || hourlyChartViewModel.isLoading || newsViewModel.isLoading {
                    ProgressView("Fetching Data...")
                        .onAppear() {
                            stockInfoViewModel.fetch(for: ticker)
                            summaryViewModel.fetch(for: ticker)
                            insightsViewModel.fetch(for: ticker)
                            historicalChartViewModel.fetch(for: ticker)
                            hourlyChartViewModel.fetch(for: ticker)
                            newsViewModel.fetch(for: ticker)
                        }
                } else if let stockInfo = stockInfoViewModel.stockInfo, let summary = summaryViewModel.summary, let marketAnalysis = insightsViewModel.marketAnalysis, let historicalChartJson = historicalChartViewModel.historicalChart, let hourlyChartJson = hourlyChartViewModel.hourlyChart, let news = newsViewModel.news {
                    
                    //Text("\(favoritesViewModel.favorites)")
                    //Text("\(favoritesViewModel.favorites.contains{$0.id==ticker})")
                    
                    NavigationStack {
                        VStack(alignment: .leading) {
                            ScrollView(.vertical, showsIndicators: true) {
                                // Stock Info
                                StockView(stockInfo: stockInfo)
                                    .padding(.horizontal)
                                
                                // Charts
                                TabView {
                                    HourlyChartWebView(htmlName: "hourly", jsonData: hourlyChartJson, color: getChartColor(stockInfo.change))
                                        .tabItem {
                                            Label("Hourly", systemImage: "chart.xyaxis.line")
                                        }
                                    
                                    HistoricalChartWebView(htmlName: "historical", jsonData: historicalChartJson)
                                    //.border(Color.red)
                                        .tabItem {
                                            Label("Historical", systemImage: "clock.fill")
                                        }
                                }
                                .frame(height: 480)
                                .padding(.bottom)
                                //.border(Color.black)
                                
                                
                                // TODO: Portfolio
                                StockPortfolioView(ticker: ticker, stockInfo: stockInfo)
                                    .padding([.horizontal, .bottom])
                                
                                // Summary
                                SummaryView(summary: summary)
                                    .padding([.horizontal, .bottom])
                                
                                // Insights
                                InsightsView(insights: marketAnalysis.insights, companyName: stockInfo.name)
                                    .padding([.horizontal, .bottom])
                                
                                // Recommendation Chart
                                RecoChartWebView(htmlName: "reco", jsonData: marketAnalysis.reco)
                                    .frame(height: 400)
                                    .padding()
                                
                                // EPS Chart
                                EPSChartWebView(htmlName: "reco", jsonData: marketAnalysis.earnings)
                                    .frame(height: 400)
                                    .padding()
                                
                                // News
                                NewsView(news: news)
                                    .padding(.horizontal)
                                //.border(Color.red)
                                
                                
                                //Spacer()
                            }
                        }
                        //.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom)
                        //.border(Color.black)
                        .navigationTitle(ticker)
                        .toolbar {
                            FavoriteButton(ticker: ticker)
                        }
                    }
                }
            }
        }
    }
    
    private func getChartColor(_ stockChange: Double) -> String {
        if stockChange > 0 {
            return "green"
        } else if stockChange < 0 {
            return "red"
        } else {
            return "black"
        }
    }
}

struct StockInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let balanceViewModel = BalanceViewModel()
        balanceViewModel.balance = 21747.26
        
        let portfolioViewModel = PortfolioViewModel()
        portfolioViewModel.loadDummyData()
        
        let favoritesViewModel = FavoritesViewModel()
        favoritesViewModel.loadDummyData()

        return StockInfoView(ticker: "QCOM")
            .environmentObject(balanceViewModel)
            .environmentObject(portfolioViewModel)
            .environmentObject(favoritesViewModel)
    }
}
