import Foundation
import Alamofire

class PortfolioViewModel: ObservableObject {
    @Published var portfolioItems: [PortfolioItem] = [] {
        didSet {
            saveOrder()
        }
    }
    @Published var isLoading = false
    @Published var isPricesUpdating = false
    
    private let portfolioOrderKey = "portfolioOrder"

    init() {
        loadOrder()
    }
    
    func movePortfolioItem(from source: IndexSet, to destination: Int) {
        portfolioItems.move(fromOffsets: source, toOffset: destination)
    }
    
    private func saveOrder() {
        let ids = portfolioItems.map { $0.id }
        UserDefaults.standard.set(ids, forKey: portfolioOrderKey)
    }
    
    private func loadOrder() {
        guard let savedOrder = UserDefaults.standard.array(forKey: portfolioOrderKey) as? [String] else { return }
        
        var orderedItems = [PortfolioItem]()
        for id in savedOrder {
            if let item = portfolioItems.first(where: { $0.id == id }) {
                orderedItems.append(item)
            }
        }
        // Add any new items that were not present at the time the order was saved
        for item in portfolioItems where !savedOrder.contains(item.id) {
            orderedItems.append(item)
        }
        portfolioItems = orderedItems
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
        loadOrder()
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
    
    func buyStock(ticker: String, quantity: Int, totalCost: Double) {
        let urlString = "\(Constants.host)/portfolio/buy"
        let parameters = [
            "ticker": ticker,
            "quantity": quantity,
            "totalCost": totalCost
        ] as [String : Any]
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success:
                    if let index = self.portfolioItems.firstIndex(where: { $0.id == ticker }) {
                        self.portfolioItems[index].quantity += quantity
                        self.portfolioItems[index].totalCost += totalCost
                    } else {
                        let newItem = PortfolioItem(id: ticker, quantity: quantity, totalCost: totalCost, latestPrice: nil)
                        self.portfolioItems.append(newItem)
                    }
                    // Fetch latest prices after updating the portfolio
                    self.fetchLatestPrices()
                    
                case .failure(let error):
                    print("Error buying stock: \(error)")
                }
            }
        }
    }
    
    func sellStock(ticker: String, quantity: Int, totalRevenue: Double) {
        let urlString = "\(Constants.host)/portfolio/sell"
        let parameters = [
            "ticker": ticker,
            "quantity": quantity,
            "totalRevenue": totalRevenue
        ] as [String : Any]
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success:
                    if let index = self.portfolioItems.firstIndex(where: { $0.id == ticker }) {
                        var currentItem = self.portfolioItems[index]
                        currentItem.quantity -= quantity
                        currentItem.totalCost = currentItem.quantity > 0 ? (currentItem.totalCost * Double(currentItem.quantity - quantity) / Double(currentItem.quantity)) : 0
                        
                        if currentItem.quantity <= 0 {
                            self.portfolioItems.remove(at: index)
                        }
                    }
                    // Fetch latest prices after updating the portfolio
                    self.fetchLatestPrices()
                    
                case .failure(let error):
                    print("Error selling stock: \(error)")
                }
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
