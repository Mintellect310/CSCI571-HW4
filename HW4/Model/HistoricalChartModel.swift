import Foundation

// struct for the stock market data entry
struct HCEntry: Decodable {
    let v: Int        // Volume
    let vw: Double    // VWAP (Volume Weighted Average Price)
    let o: Double     // Open price
    let c: Double     // Close price
    let h: Double     // High price
    let l: Double     // Low price
    let t: Int64      // Timestamp
    let n: Int        // Number of trades

    private enum CodingKeys: String, CodingKey {
        case v, vw, o, c, h, l, t, n
    }
}

// struct for the overall data structure
struct HistoricalChart: Decodable {
    let ticker: String
    let queryCount: Int
    let resultsCount: Int
    let adjusted: Bool
    let results: [HCEntry]
    let status: String
    let request_id: String
    let count: Int
}
