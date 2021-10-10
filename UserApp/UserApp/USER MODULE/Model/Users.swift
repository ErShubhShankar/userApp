//
//  Users.swift
//  CNSApp
//
//  Created by Shubham Joshi on 10/10/21.
//

import Foundation


// MARK: - UserResponse
struct Users: Codable, CustomStringConvertible {
    let data: [User]?
}

struct User: Codable, CustomStringConvertible {
    let id: String?
    let title: String?
    let firstName: String?
    let lastName: String?
    let email: String?
    let picture: String?
}
