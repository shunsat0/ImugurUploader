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
        textView.isSelectable = true
        textView.dataDetectorTypes = .all
        textView.backgroundColor = UIColor.clear
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}

struct ListView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
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
                                
                                EditableTextView(text: item)                           }
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

