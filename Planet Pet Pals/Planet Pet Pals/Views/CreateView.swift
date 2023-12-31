//
//  AddView.swift
//  Planet Pet Pals
//
//  Created by Liene on 09/12/2023.
//

import SwiftUI
import PhotosUI

struct CreateView: View {
    @StateObject private var viewModel = CreateViewModel()
    @AppStorage("selectedRegion") var selectedRegion: String = "Europe"
    
    @State private var title = ""
    @State private var description = ""
    @State private var type = "cat"
    
    @State private var image: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem?
    @State private var geopoint: CLLocationCoordinate2D? = nil
    
    @Binding var showCreateView: Bool
    @Binding var showButton: Bool
    @State private var showPhotosPicker: Bool = false
    
    @State private var showMissingFieldAlert = false
    @State private var missingField = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                MainBackground()
                VStack {
                    MainNavigationBar(
                        title: "Create",
                        leftButton: LeftNavigationButton(
                            action: { self.showCreateView = false },
                            imageName: "chevron.up",
                            buttonText: "Back",
                            imageInvisible: false,
                            textInvisible: false
                        ),
                        rightButton: RightNavigationButton(
                            action: {},
                            imageName: "chevron.up",
                            buttonText: "Back",
                            imageInvisible: true,
                            textInvisible: true
                        )
                    )
                    Form {
                        informationSection
                        imageSection
                        locationSection
                        
                        // MARK: Upload
                        Button(action: {
                            Task {
                                if selectedItem == nil {
                                    missingField = "Image"
                                    showMissingFieldAlert = true
                                    print("Missing image. Value: \(String(describing: selectedItem))")
                                } else if title.isEmpty {
                                    missingField = "Title"
                                    showMissingFieldAlert = true
                                    print("Missing title. Value: \(title)")
                                } else if description.isEmpty {
                                    missingField = "Description"
                                    showMissingFieldAlert = true
                                    print("Missing description. Value: \(description)")
                                } else if geopoint == nil {
                                    missingField = "Location"
                                    showMissingFieldAlert = true
                                    print("Missing location. Value: \(String(describing: geopoint))")
                                } else {
                                    await viewModel.loadImage(item: selectedItem)
                                    if let item = selectedItem, let geopoint = geopoint {
                                        do {
                                            try await viewModel.saveImage(item: item, title: title, type: type, description: description, location: geopoint)
                                        } catch {
                                            print("Failed to upload post: \(error)")
                                        }
                                    }
                                }
                            }
                        }) {
                            Text("Upload")
                                .font(.custom("Baloo2-SemiBold", size: 20))
                        }
                    }
                    .scrollContentBackground(.hidden)
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
        .alert(isPresented: $showMissingFieldAlert) {
            Alert(
                title: Text("Missing Field"),
                message: Text("Please provide a value for the following field: \(missingField)"),
                dismissButton: .default(Text("OK")) {
                    showMissingFieldAlert = false
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
//                await viewModel.fetchUser()
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
                        .font(.custom("Baloo2-SemiBold", size: 30))
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

// MARK: Preview
struct Preview: PreviewProvider {
    static var previews: some View {
        CreateView(showCreateView: .constant(true), showButton: .constant(true))
    }
}


// MARK: Extension
extension CreateView {
    var informationSection: some View {
        FormSection(headerText: "Information") {
            LimitedTextField(text: $title, maxLength: 30, title: "Title")
            LimitedTextField(text: $description, maxLength: 200, title: "Description")
            Picker("Type", selection: $type) {
                ForEach(animals, id: \.self) {
                    Text($0)
                }
            }
            .font(.custom("Baloo2-Regular", size: 20))
        }
    }
    
    var imageSection: some View {
        FormSection(headerText: "Image") {
            HStack {
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                        .padding(.trailing)
                    
                }
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Text("Select photo")
                        .font(.custom("Baloo2-Regular", size: 20))
                }
            }
        }
    }

    var locationSection: some View {
        FormSection(headerText: "Location") {
            CustomMapView(centerCoordinate: Binding(
                get: { self.geopoint ?? CLLocationCoordinate2D() },
                set: { self.geopoint = $0 }
            ), selectedRegion: selectedRegion)
            .frame(width: 300, height: 300)
            if let coordinate = geopoint {
                Text("Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
            }
        }
    }
}
