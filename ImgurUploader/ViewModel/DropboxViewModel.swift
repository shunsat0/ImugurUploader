//
//  DropboxViewModel.swift
//  ImgurUploader
//
//  Created by SHUN SATO on 2024/10/19.
//

import SwiftUI
import SwiftyDropbox

class DropboxViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var files: [Files.Metadata] = []
    @Published var selectedImage: UIImage? = nil
    @Published var isLoading = false
    @Published var dropboxImages: [String: UIImage] = [:]
    @Published var isLoggedOut = false
    
    init() {
        checkAuthentication()
    }
    
    func checkAuthentication() {
        isAuthenticated = DropboxClientsManager.authorizedClient != nil
    }
    
    func performLogin() {
        let scopeRequest = ScopeRequest(
            scopeType: .user,
            scopes: [
                "account_info.read",
                "files.metadata.read",
                "files.content.read"
            ],
            includeGrantedScopes: false
        )
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: nil,
            loadingStatusDelegate: nil,
            openURL: { (url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil) },
            scopeRequest: scopeRequest
        )
    }
    
    func listFiles() {
        guard let client = DropboxClientsManager.authorizedClient else {
            print("User is not logged in")
            return
        }
        
        isLoading = true
        client.files.listFolder(path: "").response { response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let result = response {
                    // 画像ファイルのみをフィルタリング
                    self.files = result.entries.filter { file in
                        if let fileMetadata = file as? Files.FileMetadata {
                            let imageExtensions = ["jpg", "jpeg", "png", "gif"]
                            return imageExtensions.contains((fileMetadata.name as NSString).pathExtension.lowercased())
                        }
                        return false
                    }
                    
                    // ファイルリストが確定した後、各画像を自動的にダウンロード
                    self.files.forEach { file in
                        self.downloadImage(file)
                    }
                } else if let error = error {
                    print("Error listing files: \(error)")
                }
            }
        }
    }
    
    
    
    func downloadImage(_ file: Files.Metadata) {
        guard let client = DropboxClientsManager.authorizedClient else {
            print("User is not logged in")
            return
        }
        
        if let fileMetadata = file as? Files.FileMetadata {
            print("Downloading image for path: \(fileMetadata.pathLower ?? "unknown")")
            client.files.download(path: fileMetadata.pathLower ?? "").response { response, error in
                if let (_, data) = response, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        // ファイルのパスをキーにして画像を保存
                        self.dropboxImages[fileMetadata.pathLower ?? ""] = image
                        print("Image downloaded and added to dictionary for path: \(fileMetadata.pathLower ?? "unknown")")
                    }
                } else if let error = error {
                    print("Error downloading file: \(error)")
                }
            }
        }
    }
    
    func logout() {
        feature/dropbox-login-fix
        DropboxClientsManager.unlinkClients()
        isAuthenticated = false
        files.removeAll()
        dropboxImages.removeAll()
        isLoggedOut = true
        print("User logged out from Dropbox.")
    }
}
