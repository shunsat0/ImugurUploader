//
//  ImgurDataModel.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/05/25.
//

import Foundation

struct ImgurDataModel: Codable {
    var data: DataInfoModel
}

struct DataInfoModel: Codable {
    var link: String
    var deletehash: String
}
