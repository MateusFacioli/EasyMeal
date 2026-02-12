struct RatingDistributionRow: View {
    let starCount: Int
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 2) {
                Text("\(starCount)")
                    .font(.caption)
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            .frame(width: 35, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: geometry.size.width * (percentage / 100), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            Text("\(Int(percentage))%")
                .font(.caption)
                .frame(width: 35, alignment: .trailing)
        }
    }
}