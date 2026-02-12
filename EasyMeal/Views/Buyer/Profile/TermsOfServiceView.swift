//
//  TermsOfServiceView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Termos de Uso")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Última atualização: 10/02/2024")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("1. Aceitação dos Termos")
                        .font(.headline)
                    
                    Text("Ao usar o EasyMeal, você concorda com estes Termos de Uso. Se você não concordar com algum dos termos, não use nosso serviço.")
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("2. Conta do Usuário")
                        .font(.headline)
                    
                    Text("Você é responsável por manter a confidencialidade de sua conta e senha. Você concorda em nos notificar imediatamente sobre qualquer uso não autorizado de sua conta.")
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("3. Uso do Serviço")
                        .font(.headline)
                    
                    Text("Você concorda em usar o serviço apenas para fins legais e de acordo com estes Termos. Você não deve usar o serviço para atividades fraudulentas ou ilegais.")
                }
            }
            .padding()
        }
        .navigationTitle("Termos de Uso")
        .navigationBarTitleDisplayMode(.inline)
    }
}