import SwiftUI
import Kingfisher

struct NewsView: View {
    var news: [NewsItem]
    @State private var selectedNewsItem: NewsItem?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("News")
                .font(.title2)
            
            if(news.count <= 0) {
                Text("News not available")
            }
            
            if let firstNewsItem = news.first {
                Button(action: { selectedNewsItem = firstNewsItem }) {
                    FirstNewsItemView(newsItem: firstNewsItem)
                }
                .buttonStyle(PlainButtonStyle())
                Divider()
            }
            
            ForEach(news.dropFirst(), id: \.id) { newsItem in
                Button(action: { selectedNewsItem = newsItem }) {
                    RestNewsItemView(newsItem: newsItem)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(item: $selectedNewsItem) { item in
            NewsDetailSheetView(newsItem: item)
        }
    }
}

struct NewsDetailSheetView: View {
    let newsItem: NewsItem
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
            }
            .padding()
            
            VStack(alignment: .leading) {
                Text(newsItem.source)
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("\(format(timestamp: newsItem.datetime))")
                    .font(.callout)
                    .foregroundStyle(.gray)
            }
            .padding()
            
            Divider()
            
            VStack(alignment: .leading) {
                Text(newsItem.headline)
                    .fontWeight(.semibold)
                    .font(.title3)
                
                Text(newsItem.summary)
                    .font(.footnote)
                
                HStack {
                    Text("For more details click").foregroundStyle(.gray)
                    
                    Link(destination: URL(string: newsItem.url)!, label: {
                        Text("here")
                    })
                }
                .font(.caption)
                .padding(.bottom)
                
                HStack {
                    Link(destination: twitterShareURL(topNewsItem: newsItem)) {
                        Image("sl_z_072523_61700_05")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    
                    Link(destination: facebookShareURL(topNewsItem: newsItem)) {
                        Image("f_logo_RGB-Blue_144")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                }
            }
            .padding([.horizontal, .bottom])
            
            Spacer()
        }
    }
}

struct FirstNewsItemView: View {
    let newsItem: NewsItem
    
    var body: some View {
        VStack(alignment: .leading) {
            KFImage(URL(string: newsItem.image))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 365, height: 200)
                .cornerRadius(10)
                .padding(.bottom)
                //.border(Color.black)
            
            // Source and time label
            HStack {
                Text(newsItem.source)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)

                Text("\(timeSincePublished(from: newsItem.datetime))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Headline text
            Text(newsItem.headline)
                .font(.headline)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
    }
}

struct RestNewsItemView: View {
    let newsItem: NewsItem
    
    var body: some View {
        HStack { //(spacing: 15) {
            VStack(alignment: .leading) {
                HStack {
                    Text(newsItem.source)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)

                    Text("\(timeSincePublished(from: newsItem.datetime))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(newsItem.headline)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(3)
            }

            Spacer()
            
            KFImage(URL(string: newsItem.image))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(10)
        }
        .padding(.vertical, 5)
    }
}

func timeSincePublished(from timestamp: Int) -> String {
    let publishedDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let now = Date()
    let timeDifference = Calendar.current.dateComponents([.day, .hour, .minute], from: publishedDate, to: now)
    
    if let days = timeDifference.day, days > 0 {
        return "\(days) d, \(timeDifference.hour ?? 0) hr"
    } else if let hours = timeDifference.hour, hours > 0 {
        return "\(hours) hr, \(timeDifference.minute ?? 0) min"
    } else if let minutes = timeDifference.minute, minutes > 0 {
        return "\(minutes) min"
    } else {
        return "Just now"
    }
}

func format(timestamp: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM dd, yyyy"
    return dateFormatter.string(from: date)
}

func twitterShareURL(topNewsItem: NewsItem) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "twitter.com"
    components.path = "/intent/tweet"

    // Create the query item for text which includes the headline and the URL
    let tweetText = "\(topNewsItem.headline) \(topNewsItem.url)"
    components.queryItems = [
        URLQueryItem(name: "text", value: tweetText)
    ]
    
    // Return the URL or a default one if there was an error
    return components.url ?? URL(string: "https://twitter.com")!
}

func facebookShareURL(topNewsItem: NewsItem) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "www.facebook.com"
    components.path = "/sharer/sharer.php"

    // Create the query item for the URL
    components.queryItems = [
        URLQueryItem(name: "u", value: topNewsItem.url)
    ]

    // Return the URL or a default one if there was an error
    return components.url ?? URL(string: "https://www.facebook.com")!
}
