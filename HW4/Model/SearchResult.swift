import Foundation

struct SearchResult: Identifiable, Decodable {
    var id = UUID()
    var description: String
    var symbol: String
}
