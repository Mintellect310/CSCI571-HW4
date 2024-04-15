import Foundation
import Alamofire

class NewsViewModel: ObservableObject {
    @Published var news: [NewsItem]?
    @Published var isLoading = false
    
    func fetch(for ticker: String) {
        isLoading = true
        let urlString = "\(Constants.host)/topNews/\(ticker)"
        
        AF.request(urlString).responseDecodable(of: [NewsItem].self) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    self.news = data
                    //print(self.news ?? "Default News")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
