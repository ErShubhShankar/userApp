//
//  Users.swift
//  CNSApp
//
//  Created by Shubham Joshi on 10/10/21.
//

import Foundation


// MARK: - UserResponse
struct Users: Codable, CustomStringConvertible {
    var data: [User]?
}

struct User: Codable, CustomStringConvertible, Hashable {
    let id: String
    var title: String? = "ms"
    let firstName: String
    let lastName: String
    let email: String?
    var picture: String? = "dfgd"
}

struct PostUser: Codable, CustomStringConvertible, Hashable {
    let firstName: String
    let lastName: String
    let email: String
}

// MARK: - UserDetail
struct UserDetail: Codable {
    let id, title, firstName: String
    let lastName: String?
    let picture: String?
    var gender, email, dateOfBirth, phone: String?
    let location: Location?
}

// MARK: - Location
struct Location: Codable {
    let street, city, state, country: String?
}

struct DeleteResponse: Codable {
    let id: String
}
