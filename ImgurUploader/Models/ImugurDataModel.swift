//
//  ImugurDataModel.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/05/25.
//

import Foundation

struct ImgurDataModel: Codable {
    let data: DataInfoModel
}

struct DataInfoModel: Codable {
    let link: String
    let deletehash: String
}
