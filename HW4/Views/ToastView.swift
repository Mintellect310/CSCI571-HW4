import SwiftUI

struct ToastView: View {
    let text: String

    var body: some View {
        Text(text)
            .padding(.vertical, 25)
            .padding(.horizontal, 60)
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(35)
    }
}

#Preview {
    ExampleView()
}

struct ExampleView: View {
    @State private var showToast = false
    
    var body: some View {
        VStack {
            Button("Show Toast") {
                showToast.toggle()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toast(isShowing: $showToast, text: "Adding AAPL to Favorites")
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, text: String) -> some View {
        self.overlay(
            VStack {
                if isShowing.wrappedValue {
                    ToastView(text: text)
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                isShowing.wrappedValue = false
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .animation(.easeInOut, value: isShowing.wrappedValue)
        )
    }
}
