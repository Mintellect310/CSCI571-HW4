import Foundation
import Alamofire
import SwiftyJSON

class SearchViewModel: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    private var searchWorkItem: DispatchWorkItem?
    
    func searchStocks(query: String) {
        searchWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            let host = "http://webtech-hw4-env.eba-h2d4kqfn.us-east-2.elasticbeanstalk.com"
            let urlString = "\(host)/autocomplete/\(query)"
            
            guard let url = URL(string: urlString), let weakSelf = self else {
                return
            }
            
            AF.request(url).responseData { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    var temp: [SearchResult] = []
                    for searchJson in json.arrayValue {
                        let description = searchJson["description"].stringValue
                        let symbol = searchJson["symbol"].stringValue
                        let searchResult = SearchResult(description: description, symbol: symbol)
                        //print("\(description)\n\(symbol)\n\(searchResult)\n====\n")
                        temp.append(searchResult)
                    }
                    //print(temp)
                    DispatchQueue.main.async {
                        weakSelf.searchResults = temp
                    }
                case .failure(let error):
                    print("Error while fetching stocks: \(error.localizedDescription))")
                }
            }
        }
        
        // Assign the new work item and schedule it after a delay.
        self.searchWorkItem = workItem
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
}
