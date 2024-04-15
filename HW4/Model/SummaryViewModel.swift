import Foundation
import Alamofire
import Combine


class SummaryViewModel: ObservableObject {
    @Published var summary: Summary?
    @Published var isLoading = false
    
    func fetchStockInfo(for ticker: String) {
        isLoading = true
        let urlString = "\(Constants.host)/summary/\(ticker)"
        
        AF.request(urlString).responseDecodable(of: Summary.self) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    self.summary = data
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
