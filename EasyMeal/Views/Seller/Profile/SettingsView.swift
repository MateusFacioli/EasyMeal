//
//  SettingsView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var darkMode = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notificações")) {
                    Toggle("Notificações Push", isOn: $notificationsEnabled)
                    Toggle("Som", isOn: $soundEnabled)
                }
                
                Section(header: Text("Aparência")) {
                    Toggle("Modo Escuro", isOn: $darkMode)
                }
                
                Section(header: Text("Privacidade")) {
                    NavigationLink("Política de Privacidade") {
                        Text("Política de Privacidade")
                    }
                    NavigationLink("Termos de Uso") {
                        Text("Termos de Uso")
                    }
                }
                
                Section {
                    Button("Limpar Cache") {
                        // Implementar limpeza de cache
                    }
                    .foregroundColor(.blue)
                    
                    Button("Exportar Dados") {
                        // Implementar exportação
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Concluir") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
