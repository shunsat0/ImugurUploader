//
//  ListView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/08.
//

import SwiftUI

struct EditableTextView: UIViewRepresentable {
    var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.isEditable = false
        textView.isSelectable = true // テキストの選択を可能にする
        textView.dataDetectorTypes = .all // URLや日付などを検出
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}

struct ListView: View {
    var body: some View {
        List {
            Section(header: Text("Uploaded Images")) {
                ForEach(photoArray.indices, id: \.self) { index in
                    let item = photoArray[index]
                    
                    if let imageUrl = URL(string: item) {
                        HStack {
                            AsyncImage(url: imageUrl) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                            
                            EditableTextView(text: item)
                                .font(.headline)
                        }
                    }
                }
            }
        }
    }
    
}



#Preview {
    ListView()
}

