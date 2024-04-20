import Foundation
import Alamofire

class PortfolioViewModel: ObservableObject {
    @Published var portfolioItems: [PortfolioItem] = [] {
        didSet {
            savePortfolio()
        }
    }
    @Published var isLoading = false
    @Published var isPricesUpdating = false
    
    init() {
        //print("Inside init:")
        loadPortfolio()
        //print("Finished init")
    }
    
    private func savePortfolio() {
        if let encoded = try? JSONEncoder().encode(portfolioItems) {
            UserDefaults.standard.set(encoded, forKey: "Portfolio")
            //print("savePortfolio: Portfolio saved successfully: \(portfolioItems)")
        } else {
            //print("savePortfolio: Failed to encode portfolio items.")
        }
    }
    
    private func loadPortfolio() {
        if let portfolioData = UserDefaults.standard.data(forKey: "Portfolio"),
           let decodedPortfolioItems = try? JSONDecoder().decode([PortfolioItem].self, from: portfolioData) {
            portfolioItems = decodedPortfolioItems
            //print("loadPortfolio: Portfolio loaded successfully: \(portfolioItems)")
        } else {
            //print("loadPortfolio: Failed to decode portfolio items.")
        }
    }
    
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
                    //self.portfolioItems = data.map { PortfolioItem(id: $0.key, quantity: $0.value.quantity, totalCost: $0.value.totalCost, latestPrice: $0.value.totalCost/Double($0.value.quantity)) }
                    //self.loadPortfolio()
                    self.fetchLatestPrices(for: data)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func fetchLatestPrices(for portfolioItemsGet: PortfolioItemsGet) {
        guard !portfolioItems.isEmpty else { return }
        isPricesUpdating = true
        let group = DispatchGroup()
        
        for item in portfolioItemsGet {
            group.enter()
            fetchLatestPrice(for: item, completion: {
                group.leave()
            })
        }

        group.notify(queue: .main) {
            self.isPricesUpdating = false
            //print(self.portfolioItems)
        }
    }
    
    func fetchLatestPrice(for dictItem: (key: String, value: PortfolioItemGet), completion: @escaping () -> Void) {
        let ticker = dictItem.key
        let portfolioItemGet = dictItem.value
        let urlString = "\(Constants.host)/stock/\(ticker)"
        
        AF.request(urlString).responseDecodable(of: StockInfo.self) { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    if let index = self.portfolioItems.firstIndex(where: { $0.id == ticker }) {
                        self.portfolioItems[index] = PortfolioItem(id: ticker, quantity: portfolioItemGet.quantity, totalCost: portfolioItemGet.totalCost, latestPrice: data.currentPrice)
                    } else {
                        self.portfolioItems.append(PortfolioItem(id: ticker, quantity: portfolioItemGet.quantity, totalCost: portfolioItemGet.totalCost, latestPrice: data.currentPrice))
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
                        let newItem = PortfolioItem(id: ticker, quantity: quantity, totalCost: totalCost, latestPrice: totalCost/Double(quantity))
                        self.portfolioItems.append(newItem)
                    }
                    // Fetch latest prices after updating the portfolio
                    //self.fetchLatestPrices()
                    
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
                        self.portfolioItems[index] = currentItem
                        
                        if currentItem.quantity <= 0 {
                            self.portfolioItems.remove(at: index)
                        }
                    }
                    // Fetch latest prices after updating the portfolio
                    //self.fetchLatestPrices()
                    
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
