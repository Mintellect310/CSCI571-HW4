import SwiftUI

struct SummaryView: View {
    private var viewModel = 
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(stockInfo.name)
                .font(.title3)
                .foregroundStyle(.gray)
                .padding(.bottom)
            HStack {
                Text("$\(String(format: "%.2f", stockInfo.currentPrice))")
                    .fontWeight(.bold)
                    .font(.title)
                Text(Image(systemName: symbolForChange(stockInfo.change)))
                    .foregroundStyle(colorForChange(stockInfo.change))
                    .font(.title2)
                Text("$\(String(format: "%.2f", stockInfo.change))")
                    .foregroundStyle(colorForChange(stockInfo.change))
                    .font(.title2)
                Text("(\(String(format: "%.2f", stockInfo.changePercent))%)")
                    .foregroundStyle(colorForChange(stockInfo.change))
                    .font(.title2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    StatsView()
}
