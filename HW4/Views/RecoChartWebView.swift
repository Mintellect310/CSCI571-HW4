import SwiftUI
import WebKit

struct RecoChartWebView: UIViewRepresentable {
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
        var parent: RecoChartWebView
        var jsonData: String?
        
        init(_ webView: RecoChartWebView) {
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
                    
                    reco = JSON.parse(`\(jsonData)`);
                    
                    Highcharts.chart("container", {
                        chart: {
                            type: 'column'
                        },
                        credits: {
                            enabled: true
                        },
                        title: {
                            text: 'Recommendation Trends'
                        },
                        xAxis: {
                            categories: reco.map(item => item.period.substring(0, 7)),
                            crosshair: true
                        },
                        yAxis: {
                            min: 0,
                            title: {
                                text: '# Analysis'
                            }
                        },
                         plotOptions: {
                            column: {
                                stacking: 'normal',
                                dataLabels: {
                                    enabled: true,
                                    // color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
                                }
                            }
                        },
                        series: [{
                            name: 'Strong Buy',
                            data: reco.map(item => item.strongBuy),
                            color: '#186f38'
                        }, {
                            name: 'Buy',
                            data: reco.map(item => item.buy),
                            color: '#1db956'
                        }, {
                            name: 'Hold',
                            data: reco.map(item => item.hold),
                            color: '#ba8b23'
                        }, {
                            name: 'Sell',
                            data: reco.map(item => item.sell),
                            color: '#f35b5c'
                        }, {
                            name: 'Strong Sell',
                            data: reco.map(item => item.strongSell),
                            color: '#813230'
                        }]
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
    RecoChartWebView(
        htmlName: "reco",
        jsonData: """
    [{"buy":16,"hold":3,"period":"2024-04-01","sell":1,"strongBuy":6,"strongSell":0,"symbol":"DELL"},{"buy":14,"hold":3,"period":"2024-03-01","sell":1,"strongBuy":6,"strongSell":0,"symbol":"DELL"},{"buy":14,"hold":3,"period":"2024-02-01","sell":1,"strongBuy":6,"strongSell":0,"symbol":"DELL"},{"buy":14,"hold":4,"period":"2024-01-01","sell":1,"strongBuy":6,"strongSell":0,"symbol":"DELL"}]
    """)
}
