//
//  WriteReviewView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


struct WriteReviewView: View {
    let seller: Seller
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = WriteReviewViewModel()
    @State private var rating = 5
    @State private var comment = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Avaliação")) {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Text("\(rating) estrelas")
                                .font(.headline)
                            
                            HStack {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                        .onTapGesture {
                                            rating = star
                                        }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Comentário")) {
                    TextEditor(text: $comment)
                        .frame(height: 100)
                    
                    Text("\(comment.count)/500")
                        .font(.caption)
                        .foregroundColor(comment.count > 500 ? .red : .gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                Section(header: Text("Fotos (opcional)")) {
                    PhotosPicker(selection: $selectedPhotos,
                               maxSelectionCount: 5,
                               matching: .images) {
                        HStack {
                            Image(systemName: "photo.fill")
                            Text("Adicionar fotos")
                        }
                    }
                    
                    if !loadedImages.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0..<loadedImages.count, id: \.self) { index in
                                    Image(uiImage: loadedImages[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                        .overlay(
                                            Button(action: {
                                                loadedImages.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Circle().fill(Color.black.opacity(0.5)))
                                            }
                                            .padding(4),
                                            alignment: .topTrailing
                                        )
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Avaliar \(seller.businessName)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Enviar") {
                    submitReview()
                }
                .disabled(comment.isEmpty || viewModel.isSubmitting)
            )
            .overlay {
                if viewModel.isSubmitting {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .onChange(of: selectedPhotos) { newItems in
                loadImages(from: newItems)
            }
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        loadedImages.removeAll()
        
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            loadedImages.append(image)
                        }
                    }
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
        }
    }
    
    private func submitReview() {
        viewModel.submitReview(
            sellerId: seller.id,
            rating: rating,
            comment: comment,
            images: loadedImages
        ) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}