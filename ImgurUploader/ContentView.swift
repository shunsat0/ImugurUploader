//
//  ContentView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/07.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var uploadedImageUrl: URL?
    @State private var showingAlert = false
    @State private var pasteString  = ""
    @State var showChildView: Bool = false
    @State private var showingToolbar = true
    @State private var slectedImage = false
    
    
    var body: some View {
                
            }
            .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: ListView()) {
                            if showingToolbar {
                                Text("ListView")
                            }
                        }
                    }
            }

            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)

            }
            .alert(isPresented: $showingAlert) {
                UIPasteboard.general.string = pasteString
                
                return Alert(
                    title: Text("Image Uploaded!"),
                    message: Text("The URL has been copied to the clipboard."),
                    dismissButton: .default(Text("OK"))
                )
            }
//            .navigationBarTitle("Imgur Uploader")
        }}
    
    func uploadImageToImgur(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            print("Failed to convert image to data")
            return
        }
        
        let url = URL(string: "https://api.imgur.com/3/image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Client-ID ac493a532606dba", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []),
                   let dictionary = json as? [String: Any],
                   let link = dictionary["data"] as? [String: Any],
                   let urlString = link["link"] as? String,
                   let url = URL(string: urlString) {
                    print("Uploaded to Imgur: \(url.absoluteString)")
                    pasteString = url.absoluteString
                    photoArray.append(url.absoluteString)
                    print(photoArray)
                    
                    DispatchQueue.main.async {
                        uploadedImageUrl = url
                        showingAlert = true
                        selectedImage = nil
                        uploadedImageUrl = nil
                        showingImagePicker = false
                    }
                }
            } else {
                print("Error: Unexpected response")
            }
        }
        
        task.resume()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}

