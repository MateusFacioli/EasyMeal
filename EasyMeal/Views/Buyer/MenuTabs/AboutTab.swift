//
//  AboutTab.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI

struct AboutTab: View {
    let seller: Seller
    let userEmail: String
    let userPhone: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Descrição do Negócio
            VStack(alignment: .leading, spacing: 10) {
                Label {
                    Text("Sobre o Negócio")
                        .font(.headline)
                } icon: {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                }
                
                Text(seller.description.isEmpty ? "Nenhuma descrição fornecida." : seller.description)
                    .font(.body)
                    .foregroundColor(seller.description.isEmpty ? .gray : .primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            // Endereço
            VStack(alignment: .leading, spacing: 10) {
                Label {
                    Text("Endereço")
                        .font(.headline)
                } icon: {
                    Image(systemName: "location.fill")
                        .foregroundColor(.red)
                }
                
                if let location = seller.currentLocation, let address = location.address, !address.isEmpty {
                    Text(address)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                } else {
                    Text("Endereço não informado")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            }
            
            // Contato
            VStack(alignment: .leading, spacing: 10) {
                Label {
                    Text("Contato")
                        .font(.headline)
                } icon: {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    
                    Text(userEmail)
                        .font(.body)
                    
                    Spacer()
                    
                    Button(action: {
                        sendEmail()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                HStack {
                    Image(systemName: "phone.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    
                    Text(userPhone.formattedPhoneNumber)
                        .font(.body)
                    
                    Spacer()
                    
                    Button(action: {
                        makePhoneCall()
                    }) {
                        Image(systemName: "phone.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Horário de Funcionamento (Resumo)
            if !seller.schedules.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Label {
                        Text("Funcionamento")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                    }
                    
                    let today = Calendar.current.component(.weekday, from: Date())
                    if let todaySchedule = seller.schedules.first(where: { $0.dayOfWeek == today && $0.isActive }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("Aberto hoje")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            Text("\(todaySchedule.startTime, style: .time) - \(todaySchedule.endTime, style: .time)")
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                    } else {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            Text("Fechado hoje")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            Text("Ver horários completos")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            
            // Distância (se disponível)
            if let distance = seller.distance {
                VStack(alignment: .leading, spacing: 10) {
                    Label {
                        Text("Distância")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.purple)
                    }
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.purple)
                        
                        Text(String(format: "Aproximadamente %.1f km de você", distance))
                            .font(.body)
                        
                        Spacer()
                        
                        Button(action: {
                            // Abrir mapa
                        }) {
                            Text("Ver rota")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    private func sendEmail() {
        if let url = URL(string: "mailto:\(userEmail)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func makePhoneCall() {
        let phone = userPhone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview
struct AboutTab_Previews: PreviewProvider {
    static var previews: some View {
        let mockSeller = Seller(
            id: "1",
            userId: "1",
            businessName: "Lanches do Zé",
            description: "Os melhores lanches da região, feitos com ingredientes frescos e muito amor. Há mais de 10 anos servindo qualidade.",
            isOnline: true,
            currentLocation: Location(latitude: -23.5505, longitude: -46.6333, address: "Rua Exemplo, 123 - Centro, São Paulo - SP"),
            schedules: [
                Schedule(
                    id: "1",
                    dayOfWeek: 2,
                    startTime: Date(),
                    endTime: Date().addingTimeInterval(28800),
                    location: Location(latitude: 0, longitude: 0),
                    isActive: true
                )
            ],
            menuId: nil,
            rating: 4.5,
            totalReviews: 42,
            isAvailableNow: true,
            profileImageURL: nil
        )
        
        ScrollView {
            AboutTab(
                seller: mockSeller,
                userEmail: "lanches@ze.com",
                userPhone: "11999999999"
            )
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
