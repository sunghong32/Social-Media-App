//
//  User.swift
//  SocialMedia
//
//  Created by 민성홍 on 2023/06/26.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?

    var userName: String
    var userBio: String
    var userBioLink: String
    var userUID: String
    var userEmail: String
    var userProfileURL: URL

    enum CodingKeys: CodingKey {
        case id
        case userName
        case userBio
        case userBioLink
        case userUID
        case userEmail
        case userProfileURL
    }
}
