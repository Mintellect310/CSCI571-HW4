import Foundation

struct MarketAnalysis: Decodable {
    let insights: Insights
    let reco: String
    let earnings: String
    
    enum CodingKeys: String, CodingKey {
        case insights, reco, earnings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        insights = try container.decode(Insights.self, forKey: .insights)
        // Convert JSON array to String for reco and earnings
        let recoData = try container.decode([Recommendation].self, forKey: .reco)
        let earningsData = try container.decode([Earning].self, forKey: .earnings)
        reco = String(data: try JSONEncoder().encode(recoData), encoding: .utf8) ?? "[]"
        earnings = String(data: try JSONEncoder().encode(earningsData), encoding: .utf8) ?? "[]"
    }
}

struct Insights: Decodable {
    let msprT: Double
    let msprP: Double
    let msprN: Double
    let changeT: Double
    let changeP: Double
    let changeN: Double

    enum CodingKeys: String, CodingKey {
        case msprT = "mspr_t"
        case msprP = "mspr_p"
        case msprN = "mspr_n"
        case changeT = "change_t"
        case changeP = "change_p"
        case changeN = "change_n"
    }
}

struct Recommendation: Codable {
    let buy, hold, sell, strongBuy, strongSell: Int
    let period, symbol: String
}

struct Earning: Codable {
    let actual, estimate: Double
    let period: String
    let quarter, year: Int
    let surprise, surprisePercent: Double
    let symbol: String
}
