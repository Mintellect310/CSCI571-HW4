import Foundation

struct Favorite {
    let id: String
    let name: String
    var currentPrice: Double
    var change: Double
    var changePercent: Double
}

typealias FavouritesGet = [String]
