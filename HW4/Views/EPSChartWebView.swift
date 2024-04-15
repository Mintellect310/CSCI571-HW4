import SwiftUI
import WebKit

struct EPSChartWebView: UIViewRepresentable {
    var htmlName: String
    var jsonData: String
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
                
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "logHandler")
        contentController.add(context.coordinator, name: "errorHandler")
        configuration.userContentController = contentController
        
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let htmlPath = Bundle.main.path(forResource: htmlName, ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath, isDirectory: false)
            let request = URLRequest(url: url)
            uiView.load(request)
            
            // Load the chart after the HTML content is fully loaded
            // uiView.navigationDelegate = context.coordinator
        }
        
        // Use Coordinator to inject JavaScript after the page loads
        //print("jsonData: \(self.jsonData)")
        context.coordinator.jsonData = self.jsonData
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: EPSChartWebView
        var jsonData: String?
        
        init(_ webView: EPSChartWebView) {
            self.parent = webView
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "logHandler" {
                print(message.body)
            } else if message.name == "errorHandler" {
                print(message.body)
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let jsonData = jsonData {
                //print("jsonData in webView: \(jsonData.prefix(1000))")
                let script = """
                    /*
                        const elemDiv = document.getElementById("jsonData");
                        if(elemDiv) elemDiv.innerText = `\(jsonData)`.slice(1000);
                    */
                    
                    earnings = JSON.parse(`\(jsonData)`);
                    
                    Highcharts.chart("container", {
                        title: {
                            text: 'Historical EPS Surprises'
                        },
                        credits: {
                            enabled: true
                        },
                        xAxis: {
                            categories: earnings.map(item => `${item.period}<br/>Surprise: ${item.surprise.toFixed(4)}`),
                        },
                        yAxis: {
                            title: {
                                text: 'Quarterly EPS'
                            }
                        },
                        tooltip: {
                            shared: true
                        },
                        series: [{
                            name: 'Actual',
                            data: earnings.map(item => item.actual),
                            type: 'spline'
                        }, {
                            name: 'Estimate',
                            data: earnings.map(item => item.estimate),
                            type: 'spline'
                        }],
                        plotOptions: {
                            spline: {
                                marker: {
                                    radius: 4
                                }
                            }
                        }
                    });
                """
                
                //print("Script:\n=======\n", script)
                
                webView.evaluateJavaScript(script, completionHandler: { (result, error) in
                    if let error = error {
                        //print("JavaScript execution error: \(error)")
                    } else if let result = result {
                        //print("JavaScript execution result: \(result)")
                    } else {
                        //print("JavaScript execution completed with no return value.")
                    }
                })
            }
        }
    }
}

#Preview() {
    EPSChartWebView(
        htmlName: "reco",
        jsonData: """
    [{"actual":2.2,"estimate":1.7621,"period":"2024-03-31","quarter":4,"surprise":0.4379,"surprisePercent":24.851,"symbol":"DELL","year":2024},{"actual":1.88,"estimate":1.4955,"period":"2023-12-31","quarter":3,"surprise":0.3845,"surprisePercent":25.7105,"symbol":"DELL","year":2024},{"actual":1.74,"estimate":1.1586,"period":"2023-09-30","quarter":2,"surprise":0.5814,"surprisePercent":50.1813,"symbol":"DELL","year":2024},{"actual":1.31,"estimate":0.8735,"period":"2023-06-30","quarter":1,"surprise":0.4365,"surprisePercent":49.9714,"symbol":"DELL","year":2024}]
    """)
}
