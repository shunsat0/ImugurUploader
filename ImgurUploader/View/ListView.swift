//
//  ListView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/08.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var images: [ImageData]
    
    var body: some View {
        List {
            ForEach(images, id: \.self) { image in
                let imageUrl = image.url
                
                HStack {
                    if let imageUrl = URL(string: imageUrl) {
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
                    }
                    
                    VStack(alignment: .leading) {
                        Text(image.url)
                            .textSelection(.enabled)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .swipeActions {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    modelContext.delete(image)
                                    // API経由でも削除する
                                }
                            }
                        
                        HStack {
                            Text("(Delete Code)")
                            
                            Text(image.deletehas)
                                .textSelection(.enabled)
                        }
                        .font(.caption2)
                        .foregroundColor(.gray)
                    }
                }
            }
        }
        
    }
    
}



#Preview {
    ListView()
}

