import SwiftUI
import WebKit

struct HourlyChartWebView: UIViewRepresentable {
    var htmlName: String
    var jsonData: String
    var color: String
    
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
        context.coordinator.color = self.color
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: HourlyChartWebView
        var jsonData: String?
        var color: String?
        
        init(_ webView: HourlyChartWebView) {
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
            if let jsonData = jsonData, let color = color {
                //print("jsonData in webView: \(jsonData.prefix(1000))")
                let script = """
                const elemDiv = document.getElementById("jsonData");
                /*if(elemDiv) elemDiv.innerText = `\(jsonData)`.slice(1000);*/
                
                data = JSON.parse(`\(jsonData)`);
                if(!data.results) {
                    document.getElementById("container").innerText = `${data.ticker} Hourly Prices N/A`;
                }
                
                const prices = data.results.map(item => ({
                    x: item.t-7*60*60*1000,
                    y: item.c
                }));
                
                Highcharts.stockChart("container", {
                    rangeSelector: {
                        enabled: false
                    },
                    exporting: {
                        enabled: false
                    },
                    navigator: {
                        enabled: false
                    },
                    title: {
                        text: `<a style="font-size: 15px">${data.ticker} Hourly Price Variation</a>`,
                        style:{
                            color: 'gray'
                        }
                    },
                    chart: {
                        type: 'line',
                        height: 430
                    },
                    xAxis: {
                        type: 'datetime',
                        dateTimeLabelFormats: {
                            hour: '%H:%M'
                        }
                    },
                    yAxis: {
                        title: {
                            text: ''
                        },
                        labels: {
                            align: 'right',
                            x: -3
                        },
                        opposite: true
                    },
                    series: [{
                        name: `${data.ticker}`,
                        data: prices,
                        color: "\(color)",
                        tooltip: {
                            valueDecimals: 2
                        }
                    }],
                    legend: {
                        enabled: false,
                    },
                    plotOptions: {
                        series: {
                            marker: {
                                enabled: false
                            }
                        }
                    },
                    credits: {
                        enabled: true
                    }
                });
            """
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
