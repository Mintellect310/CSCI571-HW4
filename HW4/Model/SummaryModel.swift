import Foundation

struct Summary: Decodable {
    let h: Double
    let l: Double
    let o: Double
    let pc: Double
    let t: Int
    let ipo: String
    let finnhubIndustry: String
    let weburl: String
    let peers: [String]

    enum CodingKeys: String, CodingKey {
        case h, l, o, pc, t, ipo
        case finnhubIndustry = "finnhubIndustry"
        case weburl = "weburl"
        case peers
    }
}
