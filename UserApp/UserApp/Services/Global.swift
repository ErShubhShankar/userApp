//
//  Global.swift
//  CNSApp
//
//  Created by Shubham Joshi on 10/10/21.
//

import UIKit

enum NetworkError: Error {
    case invalidURL
    case responseError
    case unknown
}

enum Constant: String {
    case baseURL = "dummyapi.io"
    case urlPath = "/data/v1"
    case appID = "615c9614942e4e9317adfdc9"
}
enum APIMethods {
    case user
    case userBy(id: String)
    case createUser
    case deleteUser(id: String)
    
    var string: String {
        switch self {
        case .user:
            return "/user"
        case .userBy(let id):
            return "/user/\(id)"
        case .createUser:
            return "/user/create"
        case .deleteUser(let id):
            return "/user/\(id)"
        }
    }
}

enum HTTPMethod: String {
    case POST
    case PUT
    case GET
    case DELETE
}


struct ImageInfo {
    var fileName: String
    var fileUrl: String
    var resizeImage: Bool
    var viewTag: Int
    var storeInCache: Bool
    var withAnimation: Bool
    var isFullPath: Bool
    var contentMode: UIView.ContentMode

  init(fileName: String = "", fileUrl: String = "",
       resizeImage: Bool = false, viewTag: Int = 0, storeInCache: Bool = true,
       withAnimation: Bool = true, isFullPath: Bool = true,
       contentMode: UIView.ContentMode = .scaleAspectFill) {

    self.fileName = fileName
    self.fileUrl = fileUrl
    self.resizeImage = resizeImage
    self.viewTag = viewTag
    self.storeInCache = storeInCache
    self.isFullPath = isFullPath
    self.withAnimation = withAnimation
    self.contentMode = contentMode
  }
}
