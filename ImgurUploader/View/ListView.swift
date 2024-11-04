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
    @StateObject private var viewModel = ImgurDataViewModel()
    
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
                        Text(imageUrl)
                            .font(.headline)
                            .foregroundColor(.blue)
                            .swipeActions {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    modelContext.delete(image)
                                    // API経由でも削除する
                                    Task {
                                        do {
                                            let response = try await viewModel.delete(hashcode: image.deletehas)
                                            print("Response: \(response)")
                                        } catch {
                                            print("Error: \(error)")
                                        }
                                    }
                                }
                            }
                            .padding(.bottom,10)
                        
                        Text("(Delete Code) \(image.deletehas)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                
                    Button {
                        UIPasteboard.general.string = imageUrl
                        print(imageUrl)
                    } label: {
                        Image(systemName: "document.on.document")
                    }
                }
            }
            
            OldListView()
            
        }
        
    }
    
}

struct OldListView: View {
    
    var body: some View {
        guard !photoArray.isEmpty else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            Section(header: Text("Old Images.(Sorry.You can not delete old images.)")) {
                ForEach(photoArray, id: \.self) { oldData in
                    HStack {
                        if let imageUrl = URL(string: oldData) {
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
                            Text(oldData)
                                .textSelection(.enabled)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        )
    }
}


#Preview {
    ListView()
}

