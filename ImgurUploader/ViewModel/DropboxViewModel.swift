//
//  DropboxViewModel.swift
//  ImgurUploader
//
//  Created by SHUN SATO on 2024/10/19.
//

import SwiftUI
import SwiftyDropbox
import FirebaseCrashlytics

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
        // 認証状態の変更をログ
        Crashlytics.crashlytics().setCustomValue(isAuthenticated, forKey: "dropbox_authenticated")
    }
    
    func performLogin() {
        let scopeRequest = ScopeRequest(
            scopeType: .user,
            scopes: [
                "files.metadata.read",
                "files.content.read"
            ],
            includeGrantedScopes: false
        )
        
        // ログイン試行をログ
        Crashlytics.crashlytics().log("Attempting Dropbox login with scopes: \(scopeRequest.scopes.joined(separator: ", "))")
        
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: nil,
            loadingStatusDelegate: nil,
            openURL: { (url: URL) -> Void in
                Crashlytics.crashlytics().log("Opening Dropbox auth URL")
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            },
            scopeRequest: scopeRequest
        )
    }
    
    func listFiles() {
        guard let client = DropboxClientsManager.authorizedClient else {
            let error = NSError(
                domain: "com.imgurUploader.dropbox",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in when attempting to list files"]
            )
            Crashlytics.crashlytics().record(error: error)
            print("User is not logged in")
            return
        }
        
        isLoading = true
        Crashlytics.crashlytics().log("Starting Dropbox file listing")
        
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
                    
                    // 成功をログ
                    Crashlytics.crashlytics().log("Successfully listed \(self.files.count) image files")
                    Crashlytics.crashlytics().setCustomValue(self.files.count, forKey: "dropbox_image_count")
                    
                    // ファイルリストが確定した後、各画像を自動的にダウンロード
                    self.files.forEach { file in
                        self.downloadImage(file)
                    }
                } else if let error = error {
                    // エラーをログ
                    Crashlytics.crashlytics().record(error: error)
                    print("Error listing files: \(error)")
                }
            }
        }
    }
    
    func downloadImage(_ file: Files.Metadata) {
        guard let client = DropboxClientsManager.authorizedClient else {
            let error = NSError(
                domain: "com.imgurUploader.dropbox",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in when attempting to download image"]
            )
            Crashlytics.crashlytics().record(error: error)
            print("User is not logged in")
            return
        }
        
        if let fileMetadata = file as? Files.FileMetadata {
            let path = fileMetadata.pathLower ?? "unknown"
            Crashlytics.crashlytics().log("Starting download for image: \(path)")
            
            client.files.download(path: path).response { response, error in
                if let (_, data) = response, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        // ファイルのパスをキーにして画像を保存
                        self.dropboxImages[path] = image
                        Crashlytics.crashlytics().log("Successfully downloaded image: \(path)")
                        print("Image downloaded and added to dictionary for path: \(path)")
                    }
                } else if let error = error {
                    // ダウンロードエラーをログ
                    Crashlytics.crashlytics().record(error: error)
                    print("Error downloading file: \(error)")
                }
            }
        }
    }
    
    func logout() {
        Crashlytics.crashlytics().log("User initiating Dropbox logout")
        DropboxClientsManager.unlinkClients()
        isAuthenticated = false
        files.removeAll()
        dropboxImages.removeAll()
        isLoggedOut = true
        
        // ログアウト成功をログ
        Crashlytics.crashlytics().setCustomValue(false, forKey: "dropbox_authenticated")
        Crashlytics.crashlytics().log("User successfully logged out from Dropbox")
        print("User logged out from Dropbox.")
    }
}
