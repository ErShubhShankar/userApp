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

struct User: Codable, CustomStringConvertible, Hashable {
    let id: String
    var title: String? = ""
    let firstName: String
    let lastName: String
    let email: String?
    var picture: String? = ""
}

// MARK: - UserDetail
struct UserDetail: Codable {
    let id, title, firstName: String
    let lastName: String?
    let picture: String?
    let gender, email, dateOfBirth, phone: String?
    let location: Location?
}

// MARK: - Location
struct Location: Codable {
    let street, city, state, country: String?
}
