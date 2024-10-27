//
//  InfoView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/08.
//

import SwiftUI
import WebUI

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
                destination: WebView(request: URLRequest(url: URL(string: "https://youten410.app/privacy-policy/imgur/terms.html")!)),
                label: {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.accentColor)
                        Text("Terms Of Service")
                    }
                }
            )
            
            NavigationLink(
                destination: WebView(request: URLRequest(url: URL(string: "https://youten410.app/privacy-policy/imgur/policy.html")!)),
                label: {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.accentColor)
                        Text("Privacy Policy")
                    }
                }
            )
            
            Button("Logout Dropbox") {
                viewModel.logout()
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
            ForEach(1...10, id: \.self) { item in
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

#Preview {
    InfoView()
}
