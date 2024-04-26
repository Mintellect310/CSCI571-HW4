import SwiftUI

struct Toast: ViewModifier {
    @Binding var isPresented: Bool
    var message: String
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                VStack {
                    Spacer()
                    Text(message)
                        .foregroundColor(.white)
                        .padding(.vertical, 25)
                        .padding(.horizontal, 60)
                        .background(Color.gray)
                        .cornerRadius(35)
                        .opacity(opacity)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: opacity)
                .onAppear {
                    // Fade in
                    withAnimation(.easeIn(duration: 0.5)) {
                        opacity = 1
                    }
                    // Fade out after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            opacity = 0
                        }
                        // Set isPresented to false after animation completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, message: String) -> some View {
        self.modifier(Toast(isPresented: isPresented, message: message))
    }
}



//#Preview {
//    ExampleView()
//}
//
//struct ExampleView: View {
//    @State private var showToast = false
//    
//    var body: some View {
//        VStack {
//            Button("Show Toast") {
//                showToast.toggle()
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .toast(isShowing: $showToast, text: "Adding AAPL to Favorites")
//    }
//}
