import SwiftUI

struct PortfolioView: View {
    var netWorth: Double
    var balance: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Net Worth")
                Text("$\(String(format: "%.2f", netWorth))")
                    .fontWeight(.bold)
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Cash Balance")
                Text("$\(String(format: "%.2f", balance))")
                    .fontWeight(.bold)
            }
        }
        .font(.title3)
    }
}

#Preview {
    PortfolioView(netWorth: 25000, balance: 25000)
}
