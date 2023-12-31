//
//  PostsView.swift
//  SocialMedia
//
//  Created by 민성홍 on 2023/06/30.
//

import SwiftUI

struct PostsView: View {
    @State private var recentsPosts: [Post] = []
    @State private var createNewPost: Bool = false

    var body: some View {
        NavigationStack {
            ReusablePostsView(posts: $recentsPosts)
                .hAlign(.center)
                .vAlign(.center)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        createNewPost.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.black, in: Circle())
                    }
                    .padding(15)
                }
                .navigationTitle("Post's")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SearchUserView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.black)
                                .scaleEffect(0.9)
                        }

                    }
                }
        }
        .fullScreenCover(isPresented: $createNewPost) {
            CreateNewPost { post in
                /// - Adding Created post at the Top of the Recent Posts
                recentsPosts.insert(post, at: 0)
            }
        }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
