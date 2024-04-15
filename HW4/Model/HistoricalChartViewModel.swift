import Foundation
import Alamofire
import SwiftyJSON

class HistoricalChartViewModel: ObservableObject {
    @Published var historicalChart: String?
    @Published var isLoading = false
    
    func fetch(for ticker: String) {
        isLoading = true
        let urlString = "\(Constants.host)/charts/\(ticker)"
        
        AF.request(urlString).responseData { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    if let jsonString = json.rawString() {
                        self.historicalChart = jsonString
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
