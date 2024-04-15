import Foundation
import Alamofire
import Combine


class StockInfoViewModel: ObservableObject {
    @Published var stockInfo: StockInfo?
    @Published var isLoading = false
    
    func fetch(for ticker: String) {
        isLoading = true
        let urlString = "\(Constants.host)/stock/\(ticker)"
        
        AF.request(urlString).responseDecodable(of: StockInfo.self) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    self.stockInfo = data
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
