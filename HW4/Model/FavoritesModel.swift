import Foundation

struct Favorite: Identifiable, Codable {
    let id: String
    let name: String
    var currentPrice: Double
    var change: Double
    var changePercent: Double
}

typealias FavoritesGet = [String]

struct ServerMessage: Decodable {
    let message: String
}
