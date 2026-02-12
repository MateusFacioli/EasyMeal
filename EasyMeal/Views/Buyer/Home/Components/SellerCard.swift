struct SellerCard: View {
    let seller: Seller
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Imagem do Comerciante
                if let profileImageURL = seller.profileImageURL,
                   let url = URL(string: profileImageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "storefront.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "storefront.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(seller.businessName)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if seller.isOnline {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    if !seller.description.isEmpty {
                        Text(seller.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    // Rating
                    if seller.rating > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            Text(seller.formattedRating)
                                .font(.caption2)
                                .fontWeight(.semibold)
                            
                            Text("(\(seller.totalReviews))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            // Informações adicionais
            HStack {
                Label {
                    Text(seller.isAvailableNow ? "Aberto agora" : "Fechado")
                        .font(.caption2)
                        .foregroundColor(seller.isAvailableNow ? .green : .red)
                } icon: {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                }
                
                Spacer()
                
                if let distance = seller.distance {
                    Label {
                        Text(String(format: "%.1f km", distance))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    } icon: {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}