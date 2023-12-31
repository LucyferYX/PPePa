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
    @Published private(set) var image: UIImage? = nil
    
    @Published var isUploading = false
    @Published var uploadCompleted = false
    @Published var showUnsupportedFormatAlert = false
    
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
    
    func loadImage(item: PhotosPickerItem?) async {
        if let item = item {
            do {
                if let imageData = try await item.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.image = uiImage
                        }
                    }
                } else {
                    print("Failed to load image data")
                    DispatchQueue.main.async {
                        self.showUnsupportedFormatAlert = true
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
                DispatchQueue.main.async {
                    self.showUnsupportedFormatAlert = true
                }
            }
        }
    }

    
    func saveImage(item: PhotosPickerItem, title: String, type: String, description: String, location: CLLocationCoordinate2D) async throws {
        guard let user = user else {
            print("User is nil")
            return
        }
        DispatchQueue.main.async {
            self.isUploading = true
        }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                print("Failed to load image data")
                DispatchQueue.main.async {
                    self.showUnsupportedFormatAlert = true
                }
                return
            }
            print("Image data loaded")
            
            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
            print("Image uploaded to storage: \(path), \(name)")
            
            let imageUrl = try await StorageManager.shared.getDownloadUrl(userId: user.userId, path: name)
            print("Image download URL: \(imageUrl)")
            
            let post = Post(postId: UUID().uuidString, userId: user.userId, title: title, type: type, description: description, geopoint: GeoPoint(latitude: location.latitude, longitude: location.longitude), image: imageUrl, likes: 0, views: 0)
            try await PostManager.shared.savePost(post: post)
            print("Post saved successfully")
            DispatchQueue.main.async {
                self.uploadCompleted = true
            }
            try await Task.sleep(nanoseconds: 1_000_000_000)
        } catch {
            print("Failed to upload post: \(error)")
        }
        DispatchQueue.main.async {
            self.isUploading = false
            self.uploadCompleted = false
        }
    }
}


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
                    closeButton
                    informationSection
                    imageSection
                    locationSection
                    
                    // MARK: Upload
                    Button(action: {
                        print("Image has these fields: \(title), \(description).")
                        Task {
                            await viewModel.loadImage(item: selectedItem)
                            if let item = selectedItem, let geopoint = geopoint {
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
        .alert(isPresented: $viewModel.showUnsupportedFormatAlert) {
            Alert(
                title: Text("Unsupported image format!"),
                message: Text("The app supports .JPEG, .PNG, .GIF image formats. Please select a different image."),
                dismissButton: .default(Text("OK")) {
                    viewModel.showUnsupportedFormatAlert = false
                }
            )
        }
        .onAppear() {
            Task {
                await viewModel.fetchUser()
            }
        }
        .onChange(of: selectedItem) { item in
            Task {
                await viewModel.loadImage(item: item)
                await viewModel.fetchUser()
            }
        }
        .overlay(Group {
            if viewModel.isUploading {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                    .onTapGesture { }
                VStack {
                    if !viewModel.uploadCompleted {
                        ProgressView()
                            .scaleEffect(2)
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("Snow")))
                    }
                    Text(viewModel.uploadCompleted ? "Uploaded!" : "Image is being uploaded, please do not close the device.")
                        .font(.custom("Baloo2-Regular", size: 30))
                        .foregroundColor(Color("Snow"))
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        })
        .onChange(of: viewModel.uploadCompleted) { completed in
            if completed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showCreateView = false
                }
            }
        }
    }
}


extension CreateView {
    var closeButton: some View {
        HStack {
            Button("Close") {
                showCreateView.toggle()
                showButton.toggle()
            }
            .foregroundColor(Color("Walnut"))
        }
    }

    var informationSection: some View {
        Section(header: Text("Information")) {
            TextField("Title", text: $title)
            TextField("Description", text: $description)
            Picker("Type", selection: $type) {
                ForEach(animals, id: \.self) {
                    Text($0)
                }
            }
        }
    }
    
    var imageSection: some View {
        Section(header: Text("Image")) {
            VStack {
                if let image = viewModel.image {
                    HStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                    }
                }
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Text("Select photo")
                }
            }
        }
    }

    var locationSection: some View {
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
