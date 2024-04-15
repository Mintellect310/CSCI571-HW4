//
//  StockView.swift
//  HW4
//
//  Created by Maheeth Reddy Maramreddy on 4/10/24.
//

import SwiftUI
import Kingfisher

struct StockView: View {
    var stockInfo: StockInfo
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(stockInfo.name)
                    .font(.title3)
                    .foregroundStyle(.gray)
                Spacer()
                KFImage(URL(string: stockInfo.logo))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipped()
                    .cornerRadius(10)
            }
            //.padding(.bottom)
            HStack {
                Text("$\(String(format: "%.2f", stockInfo.currentPrice))")
                    .fontWeight(.semibold)
                    .font(.largeTitle)
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
    let stockInfo = StockInfo(ticker: "AAPL", name: "Apple Inc", exchange: "NASDAQ NMS - GLOBAL MARKET", logo: "https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AAPL.png", currentPrice: 172.57, change: 1.20, changePercent: 0.70, timestamp: 1712779201, marketClose: true)
    return StockView(stockInfo: stockInfo)
}
