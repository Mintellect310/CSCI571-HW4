import Foundation

struct PortfolioItemGet: Decodable {
    var quantity: Int
    var totalCost: Double
}

typealias PortfolioItemsGet = [String: PortfolioItemGet]

struct PortfolioItem: Identifiable, Codable {
    let id: String
    var quantity: Int
    var totalCost: Double
    var latestPrice: Double?
}
