import Foundation

struct NewsItem: Decodable, Identifiable, Equatable {
    let id: UUID
    let source: String
    let datetime: Int
    let headline: String
    let summary: String
    let url: String
    let image: String

    enum CodingKeys: String, CodingKey {
        case source, datetime, headline, summary, url, image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        source = try container.decode(String.self, forKey: .source)
        datetime = try container.decode(Int.self, forKey: .datetime)
        headline = try container.decode(String.self, forKey: .headline)
        summary = try container.decode(String.self, forKey: .summary)
        url = try container.decode(String.self, forKey: .url)
        image = try container.decode(String.self, forKey: .image)
        id = UUID()  // Generate a new UUID
    }
    
    static func == (lhs: NewsItem, rhs: NewsItem) -> Bool {
        // Compare based on the unique identifier
        return lhs.id == rhs.id
    }
}
