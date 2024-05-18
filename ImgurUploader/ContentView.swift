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
    @State var showChildView: Bool = false
    @State private var showingToolbar:Bool = true
    @State private var isUploading:Bool = false
    
    @State var selectedItem: PhotosPickerItem?
    @State var image: UIImage?
    @State var isSelected: Bool = false
    
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Spacer()
                
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                }
                
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label(
                        title: { Text("Pick a Photo") },
                        icon: { Image(systemName: "photo") }
                    )
                }
                .onChange(of: selectedItem) {
                    Task {
                        guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
                        guard let uiImage = UIImage(data: imageData) else { return }
                        image = uiImage
                        isSelected = true
                    }
                }
                                
                Button(action: {
                    showingToolbar = false
                    
                    Task {
                        //upload to imgur
                    }
                    
                }, label: {
                    Text("Start Upload")
                        .padding(5)
                        .background(isSelected ? .blue : .gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
                .disabled(!isSelected)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ListView()) {
                        if showingToolbar {
                            Text("Uploaded Images")
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
            .alert(isPresented: $showingAlert) {
                UIPasteboard.general.string = pasteString
                
                return Alert(
                    title: Text("Image Uploaded!"),
                    message: Text("The URL has been copied to the clipboard."),
                    dismissButton: .default(Text("OK"))
                )
            }
            
        }
    }
    
}


#Preview {
    ContentView()
}

