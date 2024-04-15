import Foundation
import Alamofire

class ChartsViewModel: ObservableObject {
    @Published var charts: Charts?
    @Published var isLoading = false
    
    func fetch(for ticker: String) {
        isLoading = true
        let urlString = "\(Constants.host)/charts/\(ticker)"
        
        AF.request(urlString).responseDecodable(of: Charts.self) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    self.charts = data
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
