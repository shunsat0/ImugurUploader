//
//  ContentView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/07.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var showingAlert:Bool = false
    @State private var pasteString:String  = ""
    @State private var showingToolbar:Bool = true
    @State var selectedItem: PhotosPickerItem?
    @State var image: UIImage?
    @State var isSelected: Bool = false
    @StateObject private var viewModel = ImgurDataViewModel()
    @StateObject private var dropboxViewModel = DropboxViewModel()
    @State private var isShowDropboxList:Bool = false
    @Environment(\.modelContext) private var modelContext
    @State private var showAd: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Spacer()
                
                ZStack {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                    }
                    
                    if(viewModel.isUploading) {
                        VStack {
                            ProgressView()
                                .scaleEffect(2.0)
                                .padding()
                            
                            Text("Uploading...")
                                .foregroundStyle(.gray)
                                .bold()
                        }
                    }
                    
                }
                
                if(!isSelected && !viewModel.isUploading) {
                    VStack {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Label(
                                title: { Text("Pick a Photo") },
                                icon: { Image(systemName: "photo") }
                            )
                            .font(.title)
                        }
                        .onChange(of: selectedItem) {
                            showingToolbar = false
                            Task {
                                guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
                                guard let uiImage = UIImage(data: imageData) else { return }
                                image = uiImage
                                isSelected = true
                            }
                        }
                        .padding()
                        
                        Button(action: {
                            
                            print(dropboxViewModel.isAuthenticated)
                            
                            if dropboxViewModel.isAuthenticated {
                                // 認証済みなら画像の一覧を取得
                                dropboxViewModel.listFiles()
                                isShowDropboxList = true
                                
                            } else {
                                // 未認証なら認証画面を表示
                                dropboxViewModel.performLogin()
                            }
                            
                        }, label: {
                            Label(
                                title: { Text("Dropbox") },
                                icon: { Image(systemName: "cloud.fill") }
                            )
                            .font(.title)
                        })
                        .padding()
                    }
                }
                
                if(isSelected && !viewModel.isUploading) {
                    HStack {
                        Button(action: {
                            Task {
                                await viewModel.postImage(image: image!)
                            }
                            
                        }, label: {
                            Text("Start Upload")
                                .padding(5)
                                .background(isSelected ? .green : .gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        })
                        .disabled(!isSelected)
                        
                        Button("Cancel") {
                            image = nil
                            isSelected.toggle()
                            showingToolbar.toggle()
                        }
                        .padding(5)
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                    }
                    .padding()
                }
                
                Spacer()
                
                BannerAd()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ListView()) {
                        if showingToolbar {
                            Image(systemName: "photo.stack.fill")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: InfoView()) {
                        if showingToolbar {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
            .interstitialAd(isPresented: $showAd)
            
            .sheet(isPresented: $isShowDropboxList) {
                let files = dropboxViewModel.files
                let images = dropboxViewModel.dropboxImages
                
                let threeColumnGrid = [
                    GridItem(.flexible(minimum: 40), spacing: 0),
                    GridItem(.flexible(minimum: 40), spacing: 0),
                    GridItem(.flexible(minimum: 40), spacing: 0),
                ]
                
                NavigationView {
                    if !files.isEmpty {
                        ScrollView {
                            LazyVGrid(columns: threeColumnGrid, spacing: 0) {
                                ForEach(files, id: \.pathLower) { file in
                                    if let image = images[file.pathLower ?? ""] {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .border(colorScheme == .dark ? .black : .white)
                                            .onTapGesture {
                                                self.image = image
                                                isShowDropboxList = false
                                                isSelected = true
                                            }
                                    } else {
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                    }
                                }
                            }
                        }
                        .navigationTitle("Dropbox Image")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    isShowDropboxList = false
                                }
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
            }

            .sheet(isPresented: $viewModel.isShowSheet,onDismiss: {
                image = nil
                showingToolbar = true
                viewModel.isShowSheet = false
                isSelected = false
                showAd = true
                
                /// データ永続化
                let newData = ImageData(url: viewModel.postedImageData!.data.link, deletehas: viewModel.postedImageData!.data.deletehash)
                modelContext.insert(newData)
            }){
                NavigationView {
                    VStack {
                        Text("Success! Copy URL👍")
                            .foregroundStyle(.green)
                            .padding()
                        
                        Text("\(viewModel.postedImageData!.data.link)")
                            .textSelection(.enabled)
                            .font(.title)
                            .foregroundStyle(.blue)
                            .toolbar {
                                ToolbarItem {
                                    Button(action: {
                                        viewModel.isShowSheet = false
                                        isSelected = false
                                    }, label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    })
                                }
                            }
                    }
                }
                
            }
        }
    }
}


#Preview {
    ContentView()
}
