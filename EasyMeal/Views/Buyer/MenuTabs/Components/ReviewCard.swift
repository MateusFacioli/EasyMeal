struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Avatar
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(review.userName.prefix(1))
                            .font(.headline)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.userName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(review.date, style: .date)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Rating
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            // Review Text
            Text(review.comment)
                .font(.body)
                .lineLimit(5)
            
            // Fotos (se houver)
            if !review.imageURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(review.imageURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            // Resposta do Comerciante (se houver)
            if let reply = review.sellerReply {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    HStack {
                        Image(systemName: "arrow.turn.right.down")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Text("Resposta do comerciante")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text(reply.date, style: .date)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Text(reply.comment)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 20)
                }
            }
            
            // Ações
            HStack {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "hand.thumbsup")
                        Text("Útil")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "flag")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding(.leading)
                
                Spacer()
                
                if review.helpfulCount > 0 {
                    Text("\(review.helpfulCount) pessoas acharam útil")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}