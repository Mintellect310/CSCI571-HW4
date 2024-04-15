import SwiftUI
import WebKit

struct HistoricalChartWebView: UIViewRepresentable {
    var htmlName: String
    var jsonData: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let htmlPath = Bundle.main.path(forResource: htmlName, ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath, isDirectory: false)
            let request = URLRequest(url: url)
            uiView.load(request)
            
            // Load the chart after the HTML content is fully loaded
            uiView.navigationDelegate = context.coordinator
        }
        
        // Use Coordinator to inject JavaScript after the page loads
        context.coordinator.jsonData = self.jsonData
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HistoricalChartWebView
        var jsonData: String?
        
        init(_ webView: HistoricalChartWebView) {
            self.parent = webView
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let jsonData = jsonData {
                let script = "processChartData('\(jsonData)');"
                webView.evaluateJavaScript(script, completionHandler: nil)
            }
        }
    }
}


#Preview {
    HistoricalChartWebView()
}
