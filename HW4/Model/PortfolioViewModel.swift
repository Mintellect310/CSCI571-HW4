import Foundation
import Alamofire

class PortfolioViewModel: ObservableObject {
    @Published var portfolioItems: [PortfolioItem] = []
    @Published var isLoading = false
    @Published var isPricesUpdating = false
    
    func movePortfolioItem(from source: IndexSet, to destination: Int) {
        portfolioItems.move(fromOffsets: source, toOffset: destination)
    }
    
    func fetch() {
        isLoading = true
        let urlString = "\(Constants.host)/portfolio"
        
        AF.request(urlString).responseDecodable(of: PortfolioItemsGet.self) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    self.portfolioItems = data.map { PortfolioItem(id: $0.key, quantity: $0.value.quantity, totalCost: $0.value.totalCost) }
                    self.fetchLatestPrices()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func fetchLatestPrices() {
        guard !portfolioItems.isEmpty else { return }
        isPricesUpdating = true
        let group = DispatchGroup()
        
        for item in portfolioItems {
            group.enter()
            fetchLatestPrice(for: item.id, completion: {
                group.leave()
            })
        }

        group.notify(queue: .main) {
            self.isPricesUpdating = false
            //print(self.portfolioItems)
        }
    }
    
    func fetchLatestPrice(for ticker: String, completion: @escaping () -> Void) {
        let urlString = "\(Constants.host)/stock/\(ticker)"
        
        AF.request(urlString).responseDecodable(of: StockInfo.self) { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    if let index = self.portfolioItems.firstIndex(where: { $0.id == ticker }) {
                        self.portfolioItems[index].latestPrice = data.currentPrice
                    }
                case .failure(let error):
                    print(error)
                }
                completion()
            }
        }
    }
    
    func loadDummyData() {
        self.portfolioItems = [
            PortfolioItem(id: "AAPL", quantity: 5, totalCost: 882.75, latestPrice: 176.55),
            PortfolioItem(id: "NVDA", quantity: 3, totalCost: 2455.67, latestPrice: 800.86),
            PortfolioItem(id: "MSFT", quantity: 8, totalCost: 2560.32, latestPrice: 421.9)
        ]
    }
}
