//
//  SearchUserView.swift
//  SocialMedia
//
//  Created by 민성홍 on 2023/07/05.
//

import SwiftUI
import FirebaseFirestore

struct SearchUserView: View {
    /// - View Properties
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(fetchedUsers) { user in
                NavigationLink {
                    ReusableProfileContent(user: user)
                } label: {
                    Text(user.userName)
                        .font(.callout)
                        .hAlign(.leading)
                }
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search User")
        .searchable(text: $searchText)
        .onSubmit(of: .search, {
            /// - Fetch User From Firebase
            Task { await searchUsers() }
        })
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty {
                fetchedUsers = []
            }
        })
    }
}

extension SearchUserView {
    func searchUsers() async {
        do {
            let documents = try await Firestore.firestore().collection("Users")
                .whereField("userName", isGreaterThanOrEqualTo: searchText)
                .whereField("userName", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()

            let users = try documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
            }

            /// - UI Must be Updated on Main Thread
            await MainActor.run(body: {
                fetchedUsers = users
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
