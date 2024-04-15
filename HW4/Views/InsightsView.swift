import SwiftUI

struct InsightsView: View {
    var insights: Insights
    var companyName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Insights").font(.title)
                .padding(.bottom, 10)
            VStack {
                Text("Insider Sentiments").font(.title)
                    .padding(.bottom, 20)
                HStack {
                    VStack(alignment: .leading) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text("\(companyName)").bold()
                        }
                        Divider()
                        
                        Text("Total").bold()
                        Divider()
                        
                        Text("Positive").bold()
                        Divider()
                        
                        Text("Negative").bold()
                        Divider()
                    }
                    .padding(.trailing)
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("MSPR").bold()
                        Divider()
                        
                        Text("\(String(format: "%.2f", insights.msprT))")
                        Divider()
                        
                        Text("\(String(format: "%.2f", insights.msprP))")
                        Divider()
                        
                        Text("\(String(format: "%.2f", insights.msprN))")
                        Divider()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Change").bold()
                        Divider()
                        
                        Text("\(String(format: "%.0f", insights.changeT))")
                        Divider()
                        
                        Text("\(String(format: "%.0f", insights.changeP))")
                        Divider()
                        
                        Text("\(String(format: "%.0f", insights.changeN))")
                        Divider()
                    }
                    .padding(.leading)
                }
            }
        }
    }
}

#Preview {
    let insights = Insights(msprT: -683.5152214000001, msprP: 200, msprN: -883.5152214000001, changeT: -3249586, changeP: 827822, changeN: -4077408)
    return InsightsView(insights: insights, companyName: "Apple Inc")
}
