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
    
    var ticker: String
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if stockInfoViewModel.isLoading || summaryViewModel.isLoading || insightsViewModel.isLoading || historicalChartViewModel.isLoading || hourlyChartViewModel.isLoading || newsViewModel.isLoading {
                    ProgressView("Fetching Data...")
                } else if let stockInfo = stockInfoViewModel.stockInfo, let summary = summaryViewModel.summary, let marketAnalysis = insightsViewModel.marketAnalysis, let historicalChartJson = historicalChartViewModel.historicalChart, let hourlyChartJson = hourlyChartViewModel.hourlyChart, let news = newsViewModel.news {
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        // Stock Info
                        StockView(stockInfo: stockInfo)
                            .padding(.horizontal)
                        
                        // TODO: Charts
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
                        
                        // Summary
                        // TODO: Are peers clickable?
                        SummaryView(summary: summary)
                            .padding([.horizontal, .bottom])
                        
                        // TODO: Recommendation Chart, EPS Chart
                        InsightsView(insights: marketAnalysis.insights, companyName: stockInfo.name)
                            .padding([.horizontal, .bottom])
                        
                        RecoChartWebView(htmlName: "reco", jsonData: marketAnalysis.reco)
                            .frame(height: 400)
                            .padding()
                        
                        EPSChartWebView(htmlName: "reco", jsonData: marketAnalysis.earnings)
                            .frame(height: 400)
                            .padding()
                        
                        // TODO: Make the sheet for each article
                        NewsView(news: news)
                            .padding(.horizontal)
                        //.border(Color.red)
                        
                        
                        //Spacer()
                    }
                }
            }
            //.frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom)
            //.border(Color.black)
            
            .navigationTitle(ticker)
            .toolbar {
                FavoriteButton()
            }
        }
        .onAppear() {
            stockInfoViewModel.fetch(for: ticker)
            summaryViewModel.fetch(for: ticker)
            insightsViewModel.fetch(for: ticker)
            historicalChartViewModel.fetch(for: ticker)
            hourlyChartViewModel.fetch(for: ticker)
            newsViewModel.fetch(for: ticker)
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

#Preview {
    StockInfoView(ticker: "AAPL")
}
