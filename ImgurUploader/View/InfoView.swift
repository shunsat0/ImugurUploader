//
//  InfoView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/08.
//

import SwiftUI
import WebUI
import WebKit

struct InfoView: View {
    @StateObject var viewModel = DropboxViewModel()
    
    var body: some View {
        List {
            NavigationLink(
                destination: TutorialView(),
                label: {
                    HStack {
                        Image(systemName: "hand.raised.fingers.spread")
                            .foregroundColor(.accentColor)
                        Text("Tutorial")
                    }
                }
            )
            
            NavigationLink(
                destination: TermsView(),
                label: {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.accentColor)
                        Text("Terms Of Service")
                    }
                }
            )
            
            NavigationLink(
                destination: PrivacyPolicyView(),
                label: {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.accentColor)
                        Text("Privacy Policy")
                    }
                }
            )
            
            Button {
                viewModel.logout()
            } label: {
                HStack {
                    Image(systemName: "figure.walk")
                    Text("Logout Dropbox")
                }
            }

        }
        .alert("Logout succeeded.", isPresented: $viewModel.isLoggedOut) {
            Button("OK") {
                
            }
        }
    }
}

struct TutorialView: View {
    var body: some View {
        TabView {
            ForEach(1...17, id: \.self) { item in
                Image("\(item)")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 0.5)
                    )
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}

struct TermsView: View {
    var body: some View {
        WebView(
            request: URLRequest(url: URL(string: "https://shunsato.me/products/imugur-uploader/#terms-of-service")!)
        )
    }
}


struct PrivacyPolicyView: View {
    var body: some View {
        WebView(
            request: URLRequest(url: URL(string: "https://shunsato.me/products/imugur-uploader/#privacy-policy")!)
        )
    }
}

#Preview {
    InfoView()
}
