import SwiftUI
import WebKit

struct HistoricalChartWebView: UIViewRepresentable {
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
        var parent: HistoricalChartWebView
        var jsonData: String?
        
        init(_ webView: HistoricalChartWebView) {
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
                // print("jsonData in webView: \(jsonData.prefix(1000))")
                let script = """
                const elemDiv = document.getElementById("jsonData");
                if(elemDiv) elemDiv.innerText = `\(jsonData)`.slice(1000);
                
                charts = JSON.parse(`\(jsonData)`);
                
                const chartData = charts?.results?.map((data) => {
                    const timestamp = data.t - 7 * 60 * 60 * 1000;
                    return [timestamp, data.o, data.h, data.l, data.c];
                });
                console.log("Chart Data:", JSON.stringify(chartData));
                
                const volumeData = charts?.results?.map((data) => {
                    const timestamp = data.t - 7 * 60 * 60 * 1000;
                    return [timestamp, data.v];
                });
                console.log("Volume Data:", JSON.stringify(volumeData));
                
                Highcharts.stockChart("container", {
                    rangeSelector: {
                      selected: 2,
                      inputEnabled: true,
                    },
                    title: {
                      text: `${charts.ticker} Historical`,
                    },
                    subtitle: {
                      text: "With SMA and Volume by Price technical indicators",
                    },
                    chart: {
                        type: "line",
                        height: 430
                      },
                    series: [
                      {
                        type: "ohlc",
                        name: `${charts.ticker} Stock Price`,
                        data: chartData,
                        id: "ohlc",
                        threshold: null,
                      },
                      {
                        type: "candlestick",
                        linkedTo: "ohlc",
                        data: chartData,
                        zIndex: 1,
                        color: "#2aa7fb",
                        marker: {
                          enabled: false,
                        },
                        enableMouseTracking: false,
                      },
                      {
                        type: "sma",
                        linkedTo: "ohlc",
                        zIndex: 1,
                        color: "#fc6844",
                        marker: {
                          enabled: false,
                        },
                      },
                      {
                        type: "column",
                        name: "Volume",
                        data: volumeData,
                        id: "volume",
                        yAxis: 1,
                        threshold: null,
                        color: "#494ab9",
                      },
                      {
                        type: "vbp",
                        linkedTo: "ohlc",
                        volumeSeriesID: "volume",
                        zIndex: -1,
                        dataLabels: {
                        enabled: false,
                        },
                        zoneLines: {
                          enabled: false,
                        },
                      },
                    ],
                    xAxis: {
                      type: "datetime",
                    },
                    yAxis: [
                    {
                      labels: {
                        align: "right",
                        x: -4,
                      },
                      title: {
                        text: "OHLC",
                        },
                        height: "60%",
                        lineWidth: 3,
                        resize: {
                          enabled: true,
                        },
                      },
                      {
                        labels: {
                          align: "right",
                          x: -3,
                        },
                        title: {
                          text: "Volume",
                        },
                        top: "65%",
                        height: "35%",
                        offset: 1,
                        lineWidth: 3,
                      },
                    ],
                    tooltip: {
                      split: true,
                    },
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
