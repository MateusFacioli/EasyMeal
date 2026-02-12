//
//  BuyerSettingsView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI

struct BuyerSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Aparência")) {
                    Toggle("Modo Escuro", isOn: $darkModeEnabled)
                }
                
                Section(header: Text("Som e Vibração")) {
                    Toggle("Som", isOn: $soundEnabled)
                    Toggle("Vibração", isOn: $vibrationEnabled)
                }
                
                Section(header: Text("Privacidade")) {
                    NavigationLink("Política de Privacidade") {
                        PrivacyPolicyView()
                    }
                    
                    NavigationLink("Termos de Uso") {
                        TermsOfServiceView()
                    }
                }
                
                Section(header: Text("Dados")) {
                    Button("Limpar Cache") {
                        clearCache()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Exportar Meus Dados") {
                        exportData()
                    }
                    .foregroundColor(.blue)
                }
                
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Versão 1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Concluir") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func clearCache() {
        // Implementar limpeza de cache
        print("Cache limpo")
    }
    
    private func exportData() {
        // Implementar exportação de dados
        print("Dados exportados")
    }
}
