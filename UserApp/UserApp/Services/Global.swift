//
//  Global.swift
//  CNSApp
//
//  Created by Shubham Joshi on 10/10/21.
//

import Foundation

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
enum APIMethods: String {
    case user
}

enum HTTPMethod: String {
    case POST
    case PUT
    case GET
}
