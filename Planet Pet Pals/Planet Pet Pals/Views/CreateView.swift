//
//  AddView.swift
//  Planet Pet Pals
//
//  Created by Liene on 09/12/2023.
//

import SwiftUI
import Firebase
import CoreLocation
import MapKit
import PhotosUI

struct CreateView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var type = ""
    
//    @State private var image: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem?
    @State private var geopoint: CLLocationCoordinate2D? = nil
//    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State private var keyboardIsShown: Bool = false
    @Binding var showCreateView: Bool
    @Binding var showButton: Bool
    
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
                        .foregroundColor(Colors.walnut)
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
//                        VStack {
//                            Button(action: {
//                                self.showingImagePicker = true
//                            }) {
//                                Text("Select Image")
//                            }
//                            if image != nil {
//                                Image(uiImage: image!)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                            }
//                        }
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            Text("Select photo")
                        }
                    }
                    Section(header: Text("Location")) {
                        PickMapView(coordinate: $geopoint)
                    }
                }
//                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
//                    ImagePicker(image: self.$inputImage)
//                }
            }
        }
    }
    
//    func loadImage() {
//        guard let inputImage = inputImage else { return }
//        image = inputImage
//    }
}

struct PickMapView: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        if let coordinate = coordinate {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            view.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: PickMapView

        init(_ parent: PickMapView) {
            self.parent = parent
        }

        func mapView(_ pickMapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.coordinate = pickMapView.centerCoordinate
        }
    }
}

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
//                        .fill(Colors.salmon)
//                        .frame(width: 10, height: 10)
//                        .matchedGeometryEffect(id: "circle\(index)", in: animation)
//                    if index != 4 {
//                        Rectangle()
//                            .fill(Colors.salmon)
//                            .frame(height: 2)
//                            .matchedGeometryEffect(id: "line\(index)", in: animation)
//                    }
//                } else if index == currentStep {
//                    Circle()
//                        .fill(Colors.salmon)
//                        .frame(width: 10, height: 10)
//                        .matchedGeometryEffect(id: "circle\(index)", in: animation)
//                    if index != 4 {
//                        Rectangle()
//                            .fill(Colors.snow)
//                            .frame(height: 2)
//                    }
//                } else {
//                    Circle()
//                        .fill(Colors.snow)
//                        .frame(width: 10, height: 10)
//                    if index != 4 {
//                        Rectangle()
//                            .fill(Colors.snow)
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
//                            .foregroundColor(Colors.salmon)
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
//                        .foregroundColor(textFields[currentStep].isEmpty ? .gray : Colors.salmon)
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
//                        .foregroundColor(Colors.salmon)
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
