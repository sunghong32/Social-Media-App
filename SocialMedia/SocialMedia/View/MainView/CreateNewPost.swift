//
//  CreateNewPost.swift
//  SocialMedia
//
//  Created by 민성홍 on 2023/06/28.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage

struct CreateNewPost: View {
    /// - Callbacks
    var onPost: (Post) -> ()

    /// - Post Properties
    @State private var postText: String = ""
    @State private var postImageData: Data?

    /// - Stored User Data from UserDefaults(AppStorage)
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userName: String = ""
    @AppStorage("user_UID") var userUID: String = ""

    /// - View Properties
    @Environment(\.dismiss) private var dismiss

    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var photoItem: PhotosPickerItem?
    @FocusState private var showKeyboard: Bool

    var body: some View {
        VStack {
            topButtonView
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }

            bodyScrollView

            Divider()

            bottomButtonView
            .foregroundColor(.black)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
        }
        .vAlign(.top)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            if let newValue {
                Task {
                    if let rawImageData = try? await newValue.loadTransferable(type: Data.self), let image = UIImage(data: rawImageData), let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                        /// UI Must be done on Main Thread
                        await MainActor.run(body: {
                            postImageData = compressedImageData
                            photoItem = nil
                        })
                    }
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
        .overlay {
            LoadingView(show: $isLoading)
        }
    }
}

extension CreateNewPost {
    private var topButtonView: some View {
        HStack {
            Menu {
                Button("Cancel", role: .destructive) {
                    dismiss()
                }
            } label: {
                Text("Cancel")
                    .font(.callout)
                    .foregroundColor(.black)
            }
            .hAlign(.leading)

            Button {
                createPost()
            } label: {
                Text("Post")
                    .font(.callout)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                    .background(.black, in: Capsule())
            }
            .disableWithOpacity(postText == "")
        }
    }

    private var bodyScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                TextField("What's happening?", text: $postText, axis: .vertical)
                    .focused($showKeyboard)

                if let postImageData, let image = UIImage(data: postImageData) {
                    GeometryReader {
                        let size = $0.size
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            /// - Delete Button
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        self.postImageData = nil
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .fontWeight(.bold)
                                        .tint(.red)
                                }
                                .padding(10)
                            }
                    }
                    .clipped()
                    .frame(height: 220)
                }
            }
            .padding(15)
        }
    }

    private var bottomButtonView: some View {
        HStack {
            Button {
                showImagePicker.toggle()
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.title3)
            }
            .hAlign(.leading)

            Button("Done") {
                showKeyboard = false
            }
        }
    }

    // MARK: Post Content To Firebase
    func createPost() {
        isLoading = true
        showKeyboard = false

        Task {
            do {
                guard let profileURL = profileURL else { return }
                /// STEP 1: Uploading Image if any
                /// Used to delete the Post(Later shown in the video)
                let imageReferenceID = "\(userUID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_Images").child(imageReferenceID)
                if let postImageData {
                    let _ = try await storageRef.putData(postImageData)
                    let downloadURL = try await storageRef.downloadURL()

                    /// STEP 3: Create Post Object With Image Id and URL
                    let post = Post(text: postText, imageURL: downloadURL, imageReferenceID: imageReferenceID, userName: userName, userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(post)
                } else {
                    /// STEP 2: Directly Post Text Data to Firebase (Since there is no Images Present)
                    let post = Post(text: postText, userName: userName, userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(post)
                }
            } catch {
                await setError(error)
            }
        }
    }

    func createDocumentAtFirebase(_ post: Post) async throws {
        /// - Writing Document to Firebase Firestore
        let _ = try Firestore.firestore().collection("Posts").addDocument(from: post, completion: { error in
            /// Post Successfully Stored at Firebase
            isLoading = false
            onPost(post)
            dismiss()
        })
    }

    // MARK: Displaying Error as Alert
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

struct CreateNewPost_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPost { _ in
            
        }
    }
}
