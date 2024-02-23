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
    @State private var isUploading = false
    @State private var progressValue = 0.0

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack {
                if let image = selectedImage {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        if(isUploading) {
                            ProgressView("Uploading…", value: progressValue, total: 100)
                            .onReceive(timer) { _ in
                                if progressValue < 100 {
                                    progressValue += 1
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Button(action: {
                            uploadImageToImgur(image: image)
                            isUploading = true
                        }, label: {
                            Text("Upload to Imgur")
                                .fontWeight(.bold)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        })
                        .padding(.horizontal)
                        
                        Button(action: {
                            selectedImage = nil
                            showingToolbar = true
                        }, label: {
                            Text("Cancel")
                                .fontWeight(.bold)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        })
                        .padding(.horizontal)
                    }
                    .padding()
                }
                
                if selectedImage == nil {
                    Button(action: {
                        showingImagePicker = true
                        showingToolbar = false
                    }, label: {
                        Text("Select Image")
                            .fontWeight(.semibold)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    })
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                
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
            
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, showingToolbar: $showingToolbar)
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
    
    func uploadImageToImgur(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            print("Failed to convert image to data")
            return
        }
        
        let url = URL(string: "https://api.imgur.com/3/image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Client-ID d6ee7fa84ca8bd2", forHTTPHeaderField: "Authorization")
        
        // Set up the request body
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Assign request body
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            isUploading.toggle()
            
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
                    addURL(url.absoluteString)
                    showingToolbar = true
                    
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
    @Binding var showingToolbar: Bool
    
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
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
            parent.showingToolbar = true
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

