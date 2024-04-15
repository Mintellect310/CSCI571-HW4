import SwiftUI
import SwiftyJSON
import Alamofire

struct File: View {
    @State private var text = "Hello!"
    
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            Text("Explore")
                .tabItem {
                    Label("Explore", systemImage: "network")
                }
            Text("Search")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            Text("Notification")
                .tabItem {
                    Label("Notification", systemImage: "bell")
                }
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .border(Color.black)
    }
    
    func getData() {
        AF.request("\(Constants.host)/autocomplete/AA")
            .responseData { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                case .failure(let error):
                    print("Error: \(error)")
                }
        }
    }
}

#Preview {
    File()
}
