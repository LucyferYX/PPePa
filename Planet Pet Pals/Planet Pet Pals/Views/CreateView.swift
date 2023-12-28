//
//  AddView.swift
//  Planet Pet Pals
//
//  Created by Liene on 09/12/2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CoreLocation
import MapKit
import PhotosUI


class CreateViewModel: ObservableObject {
    @Published private(set) var user: DatabaseUser? = nil
    
    func fetchUser() async {
        do {
            if let userId = Auth.auth().currentUser?.uid {
                let fetchedUser = try await UserManager.shared.getUser(userId: userId)
                DispatchQueue.main.async {
                    self.user = fetchedUser
                }
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
    
    
    func saveImage(item: PhotosPickerItem, title: String, type: String, description: String, location: CLLocationCoordinate2D) {
        guard let user = user else {
            print("User is nil")
            return
        }
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    print("Failed to load image data")
                    return
                }
                print("Image data loaded")
                
                let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
                print("Image uploaded to storage: \(path), \(name)")
                
                let imageUrl = try await StorageManager.shared.getDownloadUrl(userId: user.userId, path: name) // pass the image name here
                print("Image download URL: \(imageUrl)")
                
                let post = Post(postId: UUID().uuidString, userId: user.userId, title: title, type: type, description: description, geopoint: GeoPoint(latitude: location.latitude, longitude: location.longitude), image: imageUrl, likes: 0, views: 0)
                try await PostManager.shared.savePost(post: post)
                print("Post saved successfully")
            } catch {
                print("Failed to upload post: \(error)")
            }
        }
    }
}



    
//    func saveImage(item: PhotosPickerItem, title: String, type: String, description: String, location: CLLocationCoordinate2D) throws {
//        guard let user else { return }
//        Task {
//            guard let data = try await item.loadTransferable(type: Data.self) else {return}
//            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
//
//            let imageUrl = await StorageManager.shared.getDownloadUrl(userId: user.userId, path: path)
//
//            let post = Post(postId: UUID().uuidString, userId: user.userId, title: title, type: type, description: description, geopoint: GeoPoint(latitude: location.latitude, longitude: location.longitude), image: imageUrl, likes: 0, views: 0)
//            try Firestore.firestore().collection("Posts").document(post.postId).setData(from: post)
//            print("Post image uploaded: \(path) and \(name)")
//        }
//    }


struct CreateView: View {
    @StateObject private var viewModel = CreateViewModel()
    @State private var title = ""
    @State private var description = ""
    @State private var type = "cat"
    
    @State private var image: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem?
    @State private var geopoint: CLLocationCoordinate2D? = nil
    
    @Binding var showCreateView: Bool
    @Binding var showButton: Bool
    @State private var showPhotosPicker: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                MainBackground()
                Form {
                    HStack {
                        Button("Close") {
                            showCreateView.toggle()
                            showButton.toggle()
                        }
                        .foregroundColor(Color("Walnut"))
                    }
                    Section(header: Text("Information")) {
                        TextField("Title", text: $title)
                        TextField("Description", text: $description)
                        Picker("Type", selection: $type) {
                            ForEach(animals, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    Section(header: Text("Image")) {
                        VStack {
                            if let image {
                                HStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                    VStack {
                                        Text("Name:")
                                        Text("Format:")
                                    }
                                }
                            }
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                Text("Select photo")
                            }
                            .onChange(of: selectedItem) { _ in
                                loadImage()
                            }
                        }
                    }
                    Section(header: Text("Location")) {
                        CustomMapView(centerCoordinate: Binding(
                            get: { self.geopoint ?? CLLocationCoordinate2D() },
                            set: { self.geopoint = $0 }
                        ))
                        .frame(width: 300, height: 300)
                        if let coordinate = geopoint {
                            Text("Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
                        }
                    }
                    
                    // MARK: Upload
                    Button(action: {
                        print("Image has these fields: \(title), \(description), \(type), \(String(describing: selectedItem)), \(String(describing: geopoint)).")
                        loadImage()
                        if let item = selectedItem, let geopoint = geopoint {
                            Task {
                                do {
                                    try await viewModel.saveImage(item: item, title: title, type: type, description: description, location: geopoint)
                                } catch {
                                    print("Failed to upload post: \(error)")
                                }
                            }
                        }
                    }) {
                        Text("Upload")
                    }


                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUser()
            }
        }
    }
    
    func loadImage() {
        if let item = selectedItem {
            Task {
                do {
                    if let imageData = try await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: imageData) {
                        image = uiImage
                    }
                    print("Selected image identifier: \(item.itemIdentifier ?? "No item")")
                } catch {
                    print("Failed to load image: \(error)")
                }
            }
        }
    }

}


struct CustomMapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setCenter(centerCoordinate, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView

        init(_ parent: CustomMapView) {
            self.parent = parent
        }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            let coordinate = (gestureRecognizer.view as? MKMapView)?.convert(location, toCoordinateFrom: gestureRecognizer.view)
            
            // Remove all existing annotations
            let allAnnotations = (gestureRecognizer.view as? MKMapView)?.annotations
            (gestureRecognizer.view as? MKMapView)?.removeAnnotations(allAnnotations ?? [])
            
            // Add a pin at the tapped location
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate!
            (gestureRecognizer.view as? MKMapView)?.addAnnotation(annotation)
            
            // Update the centerCoordinate
            parent.centerCoordinate = coordinate!
            
            print("Tapped at latitude: \(coordinate!.latitude), longitude: \(coordinate!.longitude)")
        }
    }
}




//struct PickMapView: UIViewRepresentable {
//    @Binding var coordinate: CLLocationCoordinate2D?
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        return mapView
//    }
//
//    func updateUIView(_ view: MKMapView, context: Context) {
//        if let coordinate = coordinate {
//            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//            view.setRegion(region, animated: true)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: PickMapView
//
//        init(_ parent: PickMapView) {
//            self.parent = parent
//        }
//
//        func mapView(_ pickMapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//            parent.coordinate = pickMapView.centerCoordinate
//        }
//    }
//}

//struct ImagePicker: UIViewControllerRepresentable {
//    @Environment(\.presentationMode) var presentationMode
//    @Binding var image: UIImage?
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        let parent: ImagePicker
//
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let uiImage = info[.originalImage] as? UIImage {
//                parent.image = uiImage
//            }
//
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//}



//struct ProgressBar: View {
//    var currentStep: Int
//    var animation: Namespace.ID
//
//    var body: some View {
//        HStack {
//            ForEach(0..<5) { index in
//                if index < currentStep {
//                    Circle()
//                        .fill(Color("Salmon"))
//                        .frame(width: 10, height: 10)
//                        .matchedGeometryEffect(id: "circle\(index)", in: animation)
//                    if index != 4 {
//                        Rectangle()
//                            .fill(Color("Salmon"))
//                            .frame(height: 2)
//                            .matchedGeometryEffect(id: "line\(index)", in: animation)
//                    }
//                } else if index == currentStep {
//                    Circle()
//                        .fill(Color("Salmon"))
//                        .frame(width: 10, height: 10)
//                        .matchedGeometryEffect(id: "circle\(index)", in: animation)
//                    if index != 4 {
//                        Rectangle()
//                            .fill(Color("Snow"))
//                            .frame(height: 2)
//                    }
//                } else {
//                    Circle()
//                        .fill(Color("Snow"))
//                        .frame(width: 10, height: 10)
//                    if index != 4 {
//                        Rectangle()
//                            .fill(Color("Snow"))
//                            .frame(height: 2)
//                    }
//                }
//            }
//        }
//        .padding()
//        .animation(.easeInOut, value: currentStep)
//    }
//}
//
//struct FormView: View {
//    @Binding var currentStep: Int
//    @Binding var textFields: [String]
//
//    var body: some View {
//        VStack {
//            TextField("Enter text", text: $textFields[currentStep])
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//            HStack {
//                if currentStep > 0 {
//                    Button(action: {
//                        currentStep -= 1
//                    }) {
//                        Text("Back")
//                            .foregroundColor(Color("Salmon"))
//                    }
//                }
//
//                Spacer()
//
//                Button(action: {
//                    if !textFields[currentStep].isEmpty {
//                        withAnimation {
//                            currentStep += 1
//                        }
//                    }
//                }) {
//                    Text("Next")
//                        .foregroundColor(textFields[currentStep].isEmpty ? .gray : Color("Salmon"))
//                }
//                .disabled(textFields[currentStep].isEmpty)
//            }
//            .padding()
//        }
//        .transition(.slide)
//    }
//}
//
//struct CreateView: View {
//    @Binding var showCreateView: Bool
//    @State private var currentStep: Int = 0
//    @State private var textFields: [String] = Array(repeating: "", count: 5)
//    @Namespace private var animation
//
//    var body: some View {
//        VStack {
//            ProgressBar(currentStep: currentStep, animation: animation)
//
//            if currentStep < 5 {
//                FormView(currentStep: $currentStep, textFields: $textFields)
//            } else {
//                Button(action: {
//                    showCreateView.toggle()
//                }) {
//                    Text("Finish")
//                        .foregroundColor(Color("Salmon"))
//                }
//            }
//        }
//    }
//}
//


//struct ContentView: View {
//    var body: some View {
//        CreateView(showCreateView: .constant(true))
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//



//struct CreateView: View {
//    @EnvironmentObject var dataManager: DataManager
//    @Binding var showAddView: Bool
//    @State var title: String = ""
//    @State var description: String = ""
//    @State var type: String = ""
//    @State var image: String = ""
//    @State var location = CLLocationCoordinate2D()
//    @State var views: Int = 0
//    @State var likes: Int = 0
//    @State var showingImagePicker = false
//    @State var inputImage: UIImage?
//
//    var body: some View {
//        NavigationView {
//            Form {
//                TextField("Title", text: $title)
//                TextField("Description", text: $description)
//                TextField("Type", text: $type)
//                TextField("Views", value: $views, formatter: NumberFormatter())
//                TextField("Likes", value: $likes, formatter: NumberFormatter())
//                Button(action: {
//                    self.showingImagePicker = true
//                }) {
//                    Text("Upload Image")
//                }
//                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
//                    ImagePicker(image: self.$inputImage)
//                }
//                Section {
//                    SelectLocationView(selectedLocation: $location)
//                        .frame(height: 300)
//                        .cornerRadius(10)
//                }
//                Button(action: {
//                    dataManager.newPost(title: title, description: description, type: type, image: image, location: location, views: views, likes: likes)
//                    self.showAddView = false
//                }) {
//                    Text("Submit")
//                }
//            }
//            .navigationBarTitle("New Post", displayMode: .inline)
//        }
//        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
//            ImagePicker(image: self.$inputImage)
//        }
//    }
//
//    func loadImage() {
//        guard let inputImage = inputImage else { return }
//        image = inputImage.jpegData(compressionQuality: 0.1)?.base64EncodedString() ?? ""
//    }
//}
//
//
//// User picks from image in their phone
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var image: UIImage?
//    @Environment(\.presentationMode) var presentationMode
//
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        let parent: ImagePicker
//
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let uiImage = info[.originalImage] as? UIImage {
//                parent.image = uiImage
//            }
//
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
//
//    }
//}
