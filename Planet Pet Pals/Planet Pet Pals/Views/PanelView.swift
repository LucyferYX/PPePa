//
//  PanelView.swift
//  Planet Pet Pals
//
//  Created by liene.krista.neimane on 08/10/2023.
//

import SwiftUI

struct PanelContent: View {
    @State private var showAboutView = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                
                SimpleButton(action: {
                    print("Username pressed")
                }, systemImage: "", buttonText: "Username", size: 30, color: Colors.linen)
                
                HStack {
                    RoundImage(systemName: "person.circle", size: 80, color: Colors.linen)
                    VStack(alignment: .leading) {
                        Text("LN3569")
                            .font(.custom("Baloo2-SemiBold", size: 20))
                            .foregroundColor(Colors.linen)
                        Text("Logout")
                            .font(.custom("Baloo2-SemiBold", size: 20))
                            .foregroundColor(Colors.linen)
                    }
                    .padding(.leading, 20)
                }
                .padding(.leading, 35)
                
                Line()
                
                ScrollView {
                    VStack {
                        ForEach(0..<10) { _ in
                            NavigationLink(destination: Text("Detail View")) {
                                CellView()
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                .background(Color.clear)
                .frame(height: 300)
                
                Line()
                
                SimpleButton(action: {
                    print("Favorites pressed")
                }, systemImage: "", buttonText: "Favorites", size: 30, color: Colors.linen)
                SimpleButton(action: {
                    print("Settings pressed")
                }, systemImage: "", buttonText: "Settings", size: 30, color: Colors.linen)
                SimpleButton(action: {
                    print("About pressed")
                    showAboutView = true
                }, systemImage: "", buttonText: "About", size: 30, color: Colors.linen)
                .sheet(isPresented: $showAboutView) {
                    AboutView()
                }
                
            }
            .frame(height: geometry.size.height)
        }
    }
}


struct PanelView: View {
    let width: CGFloat
    let showPanelView: Bool
    let closePanelView: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                PanelContent()
                    .frame(width: self.width)
                    .background(Colors.walnut)
                    .offset(x: showPanelView ? 0 : -self.width)
                Spacer()
            }
            .background(Colors.walnut.opacity(showPanelView ? 0.5 : 0.0))
            // Closing view with tap or sliding from right side
            .onTapGesture {
                withAnimation(.easeIn.delay(0.1)) {
                    self.closePanelView()
                }
            }
            .gesture(DragGesture().onEnded { value in
                if value.translation.width < -self.width / 2 {
                    withAnimation {
                        self.closePanelView()
                    }
                }
            })
        }
    }
}
