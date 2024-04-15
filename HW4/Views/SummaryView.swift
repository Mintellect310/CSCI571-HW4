import SwiftUI

struct SummaryView: View {
    var summary: Summary
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Stats").font(.title)
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("High Price:").bold()
                            Text("$\(String(format: "%.2f", summary.h))")
                        }
                        HStack {
                            Text("Low Price:").bold()
                            Text("$\(String(format: "%.2f", summary.l))")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Open Price:").bold()
                            Text("$\(String(format: "%.2f", summary.o))")
                        }
                        HStack {
                            Text("Prev. Close:").bold()
                            Text("$\(String(format: "%.2f", summary.pc))")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("About").font(.title)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("IPO Start Date:").bold()
                        Text("Industry:").bold()
                        Text("Webpage:").bold()
                        Text("Company Peers:").bold()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(summary.ipo)")
                        Text("\(summary.finnhubIndustry)")
                        ScrollView(.horizontal, showsIndicators: false) {
                            Link("\(summary.weburl)", destination: URL(string: summary.weburl)!)
                        }
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack(spacing: 8) {
                                ForEach(summary.peers, id: \.self) { peer in
                                    NavigationLink(
                                        destination: StockInfoView(ticker: peer),
                                        label: {
                                            Text(peer+",")
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    let summary = Summary(h: 169.09, l: 167.11, o: 168.84, pc: 169.67, t: 1712779201, ipo: "1980-12-12", finnhubIndustry: "Technology", weburl: "https://shop.advanceautoparts.com/", peers: ["AAPL","DELL","SMCI","HPQ","WDC","HPE","NTAP","PSTG","XRX"])
    return SummaryView(summary: summary)
}
