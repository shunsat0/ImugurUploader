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
            openURL: { (url: URL) -> Void in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            },
            scopeRequest: scopeRequest
        )
    }

    func handleOpenURL(_ url: URL) {
        let oauthCompletion: DropboxOAuthCompletion = {
            if let authResult = $0 {
                switch authResult {
                case .success:
                    print("Success! User is logged into DropboxClientsManager.")
                    self.isAuthenticated = true
                case .cancel:
                    print("Authorization flow was manually canceled by user!")
                case .error(_, let description):
                    print("Error: \(String(describing: description))")
                }
            }
        }
        DropboxClientsManager.handleRedirectURL(url, backgroundSessionIdentifier: "patata", completion: oauthCompletion)
    }

    func listFiles() {
        guard let client = DropboxClientsManager.authorizedClient else {
            print("User is not logged in")
            return
        }

        isLoading = true
        client.files.listFolder(path: "").response { response, error in
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
                print("Filtered files: \(self.files)")
            } else if let error = error {
                print("Error listing files: \(error)")
            }
        }
    }

    func downloadImage(_ file: Files.Metadata) {
        guard let client = DropboxClientsManager.authorizedClient else {
            print("User is not logged in")
            return
        }

        if let fileMetadata = file as? Files.FileMetadata {
            client.files.download(path: fileMetadata.pathLower ?? "").response { response, error in
                if let (_, data) = response {
                    // ダウンロードしたデータをUIImageに変換して表示用に保存
                    if let image = UIImage(data: data) {
                        self.selectedImage = image
                    } else {
                        print("Downloaded data is not a valid image")
                    }
                } else if let error = error {
                    print("Error downloading file: \(error)")
                }
            }
        }
    }
}
