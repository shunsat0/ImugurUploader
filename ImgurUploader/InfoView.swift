//
//  InfoView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/08.
//

import SwiftUI

struct InfoView: View {
    
    var body: some View {
        TabView {
            ForEach(1...8, id: \.self) { item in
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
