//
//  ContentView.swift
//  SocialMedia
//
//  Created by 민성홍 on 2023/06/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") private var logStatus: Bool = false
    var body: some View {
        // MARK: Redirecting User Based on Log Status
        if logStatus {
            Text("Main View")
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
