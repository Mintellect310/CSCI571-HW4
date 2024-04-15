import Foundation
import Alamofire

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Favorite] = [] {
        didSet {
            saveFavorites()
        }
    }
    @Published var isLoading = false
    @Published var isPricesUpdating = false
    
    init() {
        loadFavorites()
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: "Favorites")
        }
    }
    
    private func loadFavorites() {
        if let favoritesData = UserDefaults.standard.data(forKey: "Favorites"),
           let decodedFavorites = try? JSONDecoder().decode([Favorite].self, from: favoritesData) {
            favorites = decodedFavorites
        }
    }
    
    func moveFavorite(from source: IndexSet, to destination: Int) {
        favorites.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteFavorite(at offsets: IndexSet) {
        // Get all tickers to delete based on the offsets
        let tickersToDelete = offsets.map { favorites[$0].id }

        // Loop through the tickers to delete and perform backend deletion
        for ticker in tickersToDelete {
            delete(ticker: ticker) { success in
                // Only if deletion is successful, remove the ticker from favorites
                if success {
                    DispatchQueue.main.async {
                        self.favorites.removeAll { $0.id == ticker }
                    }
                }
            }
        }
    }
    
    func fetch() {
        isLoading = true
        let urlString = "\(Constants.host)/watchlist"
        
        AF.request(urlString).responseDecodable(of: FavoritesGet.self) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    self.fetchLatestPrices(for: data)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func fetchLatestPrices(for tickers: [String]) {
        guard !tickers.isEmpty else { return }
        isPricesUpdating = true
        let group = DispatchGroup()
        
        for ticker in tickers {
            group.enter()
            fetchLatestPrice(for: ticker, completion: {
                group.leave()
            })
        }

        group.notify(queue: .main) {
            self.isPricesUpdating = false
            //print(self.favorites)
        }
    }
    
    func fetchLatestPrice(for ticker: String, completion: @escaping () -> Void) {
        let urlString = "\(Constants.host)/stock/\(ticker)"
        
        AF.request(urlString).responseDecodable(of: StockInfo.self) { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    if let index = self.favorites.firstIndex(where: { $0.id == data.ticker }) {
                        self.favorites[index] = Favorite(id: data.ticker, name: data.name, currentPrice: data.currentPrice, change: data.change, changePercent: data.changePercent)
                    } else {
                        self.favorites.append(Favorite(id: data.ticker, name: data.name, currentPrice: data.currentPrice, change: data.change, changePercent: data.changePercent))
                    }
                case .failure(let error):
                    print(error)
                }
                completion()
            }
        }
    }
    
    func add(ticker: String) {
        let urlString = "\(Constants.host)/watchlist/\(ticker)"
        
        AF.request(urlString, method: .post).responseDecodable(of: ServerMessage.self) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let message):
                    print(message.message)
                    if let statusCode = response.response?.statusCode, statusCode == 200 {
                        self.fetchLatestPrice(for: ticker) {
                            print("Fetched newly added ticker data")
                        }
                    }
                case .failure(let error):
                    print("Error adding \(ticker) to watchlist: \(error)")
                }
            }
        }
    }
    
    func delete(ticker: String, completion: @escaping (Bool) -> Void) {
        let urlString = "\(Constants.host)/watchlist/\(ticker)"
        
        AF.request(urlString, method: .delete).responseDecodable(of: ServerMessage.self) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let message):
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 200 {
                            print(message.message)
                            completion(true)
                        } else if statusCode == 404 {
                            print(message.message)
                            completion(false)
                        }
                    }
                case .failure(let error):
                    print("Error in deleting \(ticker) from watchlist: \(error)")
                    completion(false)
                }
            }
        }
    }
    
    func loadDummyData() {
        self.favorites = [
            Favorite(id: "NVDA", name: "NVIDIA Corp", currentPrice: 881.86, change: -24.3, changePercent: -2.6816),
            Favorite(id: "AAPL", name: "Apple Inc", currentPrice: 176.55, change: 1.51, changePercent: 0.8627),
        ]
    }
}
