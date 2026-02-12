struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Política de Privacidade")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Última atualização: 10/02/2024")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("1. Informações que Coletamos")
                        .font(.headline)
                    
                    Text("Coletamos informações que você nos fornece diretamente, como nome, endereço de email, número de telefone e localização quando você usa nossos serviços.")
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("2. Como Usamos Suas Informações")
                        .font(.headline)
                    
                    Text("Usamos suas informações para fornecer, manter e melhorar nossos serviços, processar transações, enviar notificações e personalizar sua experiência.")
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("3. Compartilhamento de Informações")
                        .font(.headline)
                    
                    Text("Não vendemos suas informações pessoais. Podemos compartilhar informações com terceiros apenas para fornecer nossos serviços ou quando exigido por lei.")
                }
            }
            .padding()
        }
        .navigationTitle("Política de Privacidade")
        .navigationBarTitleDisplayMode(.inline)
    }
}