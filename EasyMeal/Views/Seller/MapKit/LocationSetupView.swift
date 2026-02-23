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
    
    @State private var searchQuery = ""
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @State private var completer = MKLocalSearchCompleter()
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    TextField("Buscar endereço ou local...", text: $searchQuery)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    if isSearching {
                        List {
                            ForEach(searchResults, id: \.self) { result in
                                VStack(alignment: .leading) {
                                    Text(result.title)
                                        .font(.headline)
                                    if !result.subtitle.isEmpty {
                                        Text(result.subtitle)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    searchLocation(result: result)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(maxHeight: 200)
                        .padding(.horizontal)
                    }
                }
                .background(Color.white)
                .zIndex(1)
                
                ZStack {
                    // Mapa com pinagem interativa
                    Map(coordinateRegion: $viewModel.region,
                        showsUserLocation: true,
                        annotationItems: [MapAnnotationItem(coordinate: viewModel.selectedLocation?.coordinate ?? viewModel.region.center)]) { annotation in
                        MapAnnotation(coordinate: annotation.coordinate, anchorPoint: CGPoint(x: 0.5, y: 1)) {
                            PinView()
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let location = value.location
                                            let mapView = MKMapView(frame: UIScreen.main.bounds)
                                            // Convert the drag gesture location in screen coordinates to map coordinates
                                            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
                                            
                                            // Since we don't have direct access to MKMapView inside the gesture,
                                            // we need to update coordinate based on viewModel.region and drag offset.
                                            // Instead, we calculate coordinate from the gesture translation relative to the center.
                                            // So manually calculate coordinate change:
                                            // We'll approximate by:
                                            // 1 degree latitude ~ 111km, longitude varies by cos(latitude)
                                            // We map gesture translation in points to coordinate offset by scaling factor.
                                            // But since this is complex, a simpler approach is to convert drag translation in screen points to coordinate offsets.
                                            // As we don't have MKMapView, we'll use a helper func to convert drag translation to coordinate offset.
                                            // So let's implement a helper function:
                                        }
                                        .onEnded { value in
                                            // Update selectedLocation's coordinate from final drag position
                                            // We'll do the coordinate calculation below
                                            let coordinate = coordinateFromDrag(value: value)
                                            viewModel.selectedLocation = Location(latitude: coordinate.latitude,
                                                                                 longitude: coordinate.longitude,
                                                                                 address: nil,
                                                                                 placeName: nil)
                                            viewModel.region.center = coordinate
                                        }
                                )
                        }
                    }
                    .ignoresSafeArea()
                    
                    // Controles
                    VStack {
                        Spacer()
                        VStack(spacing: 15) {
                            Text("Arraste o mapa para ajustar a localização")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                viewModel.saveLocation()
                                if !viewModel.isLoading {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }) {
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
                                if let currentLocation = viewModel.selectedLocation {
                                    viewModel.region.center = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                                }
                            }
                            .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .shadow(radius: 10)
                    }
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
                completer.resultTypes = .address
                completer.region = viewModel.region
                completer.delegate = coordinator
            }
            .onChange(of: searchQuery) { newValue in
                completer.queryFragment = newValue
            }
            .onChange(of: completer.results) { newResults in
                searchResults = newResults
                isSearching = !newResults.isEmpty && !searchQuery.isEmpty
            }
        }
    }
    
    private func searchLocation(result: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = result.title + " " + result.subtitle
        searchRequest.region = viewModel.region
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard error == nil,
                  let coordinate = response?.mapItems.first?.placemark.coordinate else {
                return
            }
            withAnimation {
                viewModel.region.center = coordinate
                let newLocation = Location(latitude: coordinate.latitude,
                                           longitude: coordinate.longitude,
                                           address: result.subtitle.isEmpty ? nil : result.subtitle,
                                           placeName: result.title)
                viewModel.selectedLocation = newLocation
                isSearching = false
                searchQuery = ""
            }
        }
    }
    
    private func coordinateFromDrag(value: DragGesture.Value) -> CLLocationCoordinate2D {
        // Calculate coordinate offset based on drag translation and current region span.
        // This is an approximation.
        
        let translation = value.translation
        
        let region = viewModel.region
        let center = region.center
        let span = region.span
        
        // Map view width and height in points (approximate)
        let mapWidth: CGFloat = UIScreen.main.bounds.width
        let mapHeight: CGFloat = UIScreen.main.bounds.height
        
        // Calculate the degrees per point
        let degreesPerPointLat = span.latitudeDelta / Double(mapHeight)
        let degreesPerPointLong = span.longitudeDelta / Double(mapWidth)
        
        let newLat = center.latitude - degreesPerPointLat * Double(translation.height)
        let newLong = center.longitude + degreesPerPointLong * Double(translation.width)
        
        return CLLocationCoordinate2D(latitude: newLat, longitude: newLong)
    }
    
    struct PinView: View {
        var body: some View {
            Image(systemName: "mappin")
                .font(.title)
                .foregroundColor(.red)
                .shadow(radius: 2)
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                        .opacity(0.75)
                        .offset(y: 10)
                )
                .offset(y: -10)
        }
    }
    
    // Coordinator for MKLocalSearchCompleterDelegate
    private var coordinator: Coordinator {
        let coordinator = Coordinator()
        coordinator.parent = self
        return coordinator
    }
    
    class Coordinator: NSObject, MKLocalSearchCompleterDelegate {
        var parent: LocationSetupView?
        
        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            DispatchQueue.main.async {
                self.parent?.searchResults = completer.results
                self.parent?.isSearching = !completer.results.isEmpty && !(self.parent?.searchQuery.isEmpty ?? true)
            }
        }
        
        func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
            // Handle error if needed
        }
    }
}
