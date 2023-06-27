//
//  SocialMediaApp.swift
//  SocialMedia
//
//  Created by 민성홍 on 2023/06/26.
//

import SwiftUI
import Firebase

@main
struct SocialMediaApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
