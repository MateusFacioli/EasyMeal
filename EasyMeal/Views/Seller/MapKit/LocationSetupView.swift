//
//  LocationSetupView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import SwiftUI
import MapKit
import Combine

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct LocationSetupView: View {
    @StateObject private var viewModel = LocationSetupViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // Mapa
                Map(coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    annotationItems: viewModel.mapAnnotations) { annotation in
                    MapMarker(coordinate: annotation.coordinate)
                }
                .ignoresSafeArea()
                
                // Marcador central
                VStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.top, 40)
                
                // Controles
                VStack {
                    Spacer()
                    VStack(spacing: 15) {
                        Text("Arraste o mapa para ajustar a localização")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button(action: viewModel.saveLocation) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Salvar Localização")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Usar Minha Localização Atual") {
                            viewModel.useCurrentLocation()
                        }
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(radius: 10)
                }
            }
            .navigationBarTitle("Definir Localização", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("Erro"),
                    message: Text(viewModel.errorMessage ?? "Erro desconhecido"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                viewModel.checkLocationPermission()
            }
        }
    }
}
