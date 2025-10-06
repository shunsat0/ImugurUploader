import SwiftUI
import PhotosUI
import SwiftyDropbox
import SwiftData
import Observation

@MainActor @Observable final class ContentViewModel {
    // MARK: - Child ViewModels
    let imgurVM: ImgurDataViewModel
    let dropboxVM: DropboxViewModel
    
    // MARK: - UI State
    var selectedItem: PhotosPickerItem?
    var image: UIImage?
    var isSelected: Bool = false
    var isShowDropboxList: Bool = false
    var alertMessage: String = ""
    var isAlertShowing: Bool = false
    
    // MARK: - Init
    init(imgurVM: ImgurDataViewModel? = nil,
         dropboxVM: DropboxViewModel? = nil) {
        self.imgurVM = imgurVM ?? ImgurDataViewModel()
        self.dropboxVM = dropboxVM ?? DropboxViewModel()
        self.selectedItem = nil
        self.image = nil
    }
    
    // MARK: - Derived State
    var isUploading: Bool { imgurVM.isUploading }
    
    // MARK: - Actions
    func onSelectedItemChanged() async {
        guard let selectedItem else { return }
        do {
            if let imageData = try await selectedItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: imageData) {
                self.image = uiImage
                self.isSelected = true
            }
        } catch {
            // 失敗時は選択をリセット
            self.selectedItem = nil
            self.isSelected = false
        }
    }
    
    func didTapDropboxButton() {
        // 認証前
        if DropboxClientsManager.authorizedClient == nil {
            dropboxVM.performLogin()
        } else {
            dropboxVM.listFiles()
            isShowDropboxList = true
        }
    }
    
    func selectDropboxImage(_ image: UIImage) {
        self.image = image
        self.isShowDropboxList = false
        self.isSelected = true
    }
    
    func startUpload() async {
        guard let image else { return }
        await imgurVM.postImage(image: image)
    }
    
    func handleOpenURL(_ url: URL) {
        let oauthCompletion: DropboxOAuthCompletion = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let authResult = result {
                    switch authResult {
                    case .success:
                        self.alertMessage = "Successfully logged in to Dropbox."
                    case .cancel:
                        self.alertMessage = "Authentication to Dropbox has been canceled."
                    case .error(_, _):
                        self.alertMessage = "An unexpected error has occurred."
                    }
                    self.isAlertShowing = true
                }
            }
        }
        DropboxClientsManager.handleRedirectURL(url, backgroundSessionIdentifier: "patata", completion: oauthCompletion)
    }
    
    func handleUploadDismiss(modelContext: ModelContext) {
        // インタースティシャル広告表示フラグを立てる
        imgurVM.isShowIntersitalAd = true
        // 画面状態のリセット
        self.image = nil
        imgurVM.isShowSheet = false
        self.isSelected = false
        // データ保存
        if let data = imgurVM.postedImageData?.data {
            let newData = ImageData(url: data.link, deletehas: data.deletehash)
            modelContext.insert(newData)
        }
    }
    
    var postedImageLink: String? {
        imgurVM.postedImageData?.data.link
    }
    
    func closeSheet() {
        imgurVM.isShowSheet = false
        isSelected = false
    }
    
    func copyLinkToPasteboard() {
        if let link = postedImageLink {
            UIPasteboard.general.string = link
        }
    }
}

