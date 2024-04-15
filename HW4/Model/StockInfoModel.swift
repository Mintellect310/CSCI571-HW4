import Foundation

struct StockInfo: Decodable {
    var ticker: String
    var name: String
    var exchange: String
    var logo: String
    var currentPrice: Double
    var change: Double
    var changePercent: Double
    var timestamp: Int
    var marketClose: Bool
    
    enum CodingKeys: String, CodingKey {
        case ticker
        case name
        case exchange
        case logo
        case currentPrice = "c"
        case change = "d"
        case changePercent = "dp"
        case timestamp = "t"
        case marketClose
    }
}
