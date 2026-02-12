struct RateOrderView: View {
    let order: Order
    @Environment(\.presentationMode) var presentationMode
    @State private var rating = 5
    @State private var comment = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Avaliação")) {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .foregroundColor(.orange)
                                .font(.title2)
                                .onTapGesture {
                                    rating = star
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                
                Section(header: Text("Comentário (opcional)")) {
                    TextEditor(text: $comment)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Avaliar Pedido")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Enviar") {
                    submitRating()
                }
                .disabled(isSubmitting)
            )
        }
    }
    
    private func submitRating() {
        isSubmitting = true
        // Implementar envio da avaliação
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSubmitting = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}