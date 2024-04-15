import Foundation
import Alamofire

class BalanceViewModel: ObservableObject {
    @Published var balance: Double?
    @Published var isLoading = false
    
    func fetch() {
        isLoading = true
        let urlString = "\(Constants.host)/balance"
        
        AF.request(urlString).responseDecodable(of: Balance.self) { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    self.balance = data.balance
                    //print(self.balance ?? "Default Balance")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func setBalance(newBalance: Double) {
        balance = newBalance
    }
}
