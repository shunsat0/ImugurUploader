//
//  ContentView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/07.
//

import SwiftUI
import PhotosUI
import SwiftyDropbox

struct ContentView: View {
    @State private var vm = ContentViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @State private var isImgurSheetPresented = false
    @State private var isInterstitialAdPresented = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                ZStack {
                    if let image = vm.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                    }

                    if vm.isUploading {
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

                if !vm.isSelected && !vm.isUploading {
                    VStack {
                        PhotosPicker(selection: $vm.selectedItem, matching: .images) {
                            Label(
                                title: { Text("Photo Library") },
                                icon: { Image(systemName: "photo") }
                            )
                            .font(.title)
                        }
                        .onChange(of: vm.selectedItem) { _, _ in
                            Task { await vm.onSelectedItemChanged() }
                        }
                        .padding()

                        Button(action: {
                            vm.didTapDropboxButton()
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

                if vm.isSelected && !vm.isUploading {
                    HStack {
                        Button(action: {
                            Task { await vm.startUpload() }
                        }, label: {
                            Text("Start Upload")
                        })
                        .buttonStyle(.borderedProminent)
                        .disabled(!vm.isSelected)

                        Button("Cancel") {
                            vm.image = nil
                            vm.isSelected.toggle()
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }

                Spacer()

                BannerAd()
            }
            .onOpenURL { url in
                vm.handleOpenURL(url)
            }
            .alert("Authentication Result", isPresented: $vm.isAlertShowing) {
                Button("OK") {}
            } message: {
                Text(vm.alertMessage)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ListView()) {
                        if !vm.isSelected {
                            Image(systemName: "photo.stack.fill")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: InfoView()) {
                        if !vm.isSelected {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $vm.isShowDropboxList) {
                let files = vm.dropboxVM.files
                let images = vm.dropboxVM.dropboxImages

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
                                                vm.selectDropboxImage(image)
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
                                    vm.isShowDropboxList = false
                                }
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
            }
            .fullScreenCover(isPresented: $isImgurSheetPresented, onDismiss: {
                isImgurSheetPresented = false
                vm.handleUploadDismiss(modelContext: modelContext)
            }){
                NavigationView {
                    VStack {
                        if let link = vm.postedImageLink {
                            Text("\(link)")
                                .font(.title)
                                .foregroundStyle(.blue)
                                .toolbar {
                                    ToolbarItem {
                                        Button(action: {
                                            vm.closeSheet()
                                        }, label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        })
                                    }
                                }
                                .padding(.bottom,15)

                            Button {
                                vm.copyLinkToPasteboard()
                            } label: {
                                Image(systemName: "document.on.document")
                            }
                            .controlSize(.large)
                        }
                    }
                    .padding()
                }
            }
        }
        .onChange(of: vm.imgurVM.isShowSheet) {
            isImgurSheetPresented = vm.imgurVM.isShowSheet
        }
        .onChange(of: vm.imgurVM.isShowIntersitalAd) {
            isInterstitialAdPresented = vm.imgurVM.isShowIntersitalAd
        }
        .onAppear {
            isImgurSheetPresented = vm.imgurVM.isShowSheet
            isInterstitialAdPresented = vm.imgurVM.isShowIntersitalAd
        }
        .interstitialAd(isPresented: $isInterstitialAdPresented)
    }
}


#Preview {
    ContentView()
}
