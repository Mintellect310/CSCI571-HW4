import Foundation
import Alamofire

class InsightsViewModel: ObservableObject {
    @Published var marketAnalysis: MarketAnalysis?
    @Published var isLoading = false
    
    func fetch(for ticker: String) {
        isLoading = true
        let urlString = "\(Constants.host)/insights/\(ticker)"
        
        AF.request(urlString).responseDecodable(of: MarketAnalysis.self) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    self.marketAnalysis = data
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
