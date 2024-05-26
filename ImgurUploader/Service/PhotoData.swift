//
//  PhotoData.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/08.
//

import Foundation
import SwiftData


// UserDefaultsからURLリストを読み込む関数
func loadURLs() -> [String] {
    UserDefaults.standard.stringArray(forKey: "savedURLs") ?? []
}

// UserDefaultsにURLリストを保存する関数
func saveURLs(_ urls: [String]) {
    UserDefaults.standard.set(urls, forKey: "savedURLs")
}

// アプリ起動時にURLリストを読み込む
var photoArray: [String] = loadURLs().reversed()

// URLを追加して保存する関数
func addURL(_ url: String) {
    photoArray.append(url)
    saveURLs(photoArray)
}



// SwiftDataを使ったデータ管理
//@Model
//final class PhotoData {
//    var url:
//}
