import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    
    let customColor = Color(red: 242/255, green: 242/255, blue: 244/255)
    
    @StateObject private var balanceViewModel = BalanceViewModel()
    @StateObject private var portfolioViewModel = PortfolioViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    
    var body: some View {
        if isActive {
            HomeScreen()
                .environmentObject(balanceViewModel)
                .environmentObject(portfolioViewModel)
                .environmentObject(favoritesViewModel)
        } else {
            ZStack {
                customColor
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image("app icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
            .onAppear() {
                balanceViewModel.fetch()
                portfolioViewModel.fetch()
                favoritesViewModel.fetch()
            }
        }
    }
}

#Preview {
    SplashScreen()
}
