//
//  AddView.swift
//  Planet Pet Pals
//
//  Created by Liene on 09/12/2023.
//

import SwiftUI
import Firebase
import CoreLocation

struct CreateView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var showAddView: Bool
    @State var title: String = ""
    @State var description: String = ""
    @State var type: String = ""
    @State var image: String = ""
    @State var location = CLLocationCoordinate2D()
    @State var views: Int = 0
    @State var likes: Int = 0
    @State var showingImagePicker = false
    @State var inputImage: UIImage?
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                TextField("Type", text: $type)
                TextField("Views", value: $views, formatter: NumberFormatter())
                TextField("Likes", value: $likes, formatter: NumberFormatter())
                Button(action: {
                    self.showingImagePicker = true
                }) {
                    Text("Upload Image")
                }
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: self.$inputImage)
                }
                Section {
                    SelectLocationView(selectedLocation: $location)
                        .frame(height: 300)
                        .cornerRadius(10)
                }
                Button(action: {
                    dataManager.newPost(title: title, description: description, type: type, image: image, location: location, views: views, likes: likes)
                    self.showAddView = false
                }) {
                    Text("Submit")
                }
            }
            .navigationBarTitle("New Post", displayMode: .inline)
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = inputImage.jpegData(compressionQuality: 0.1)?.base64EncodedString() ?? ""
    }
}


// User picks from image in their phone
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
}
