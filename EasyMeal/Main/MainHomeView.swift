//
//  MainHomeView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import SwiftUI
import Combine

struct MainHomeView: View {
    @StateObject private var sellerAuthVM = SellerAuthViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @State private var navigateToSignup = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("EasyMeal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Conectando comerciantes e clientes")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Como você quer usar o app?")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Button(action: {
                            sellerAuthVM.userType = .seller
                            navigateToSignup = true
                        }) {
                            UserTypeCard(
                                icon: "storefront.fill",
                                title: "Sou Comerciante",
                                subtitle: "Vendo alimentos ou bebidas",
                                color: .blue
                            )
                        }
                        
                        Button(action: {
                            sellerAuthVM.userType = .buyer
                            navigateToSignup = true
                        }) {
                            UserTypeCard(
                                icon: "person.fill",
                                title: "Sou Cliente",
                                subtitle: "Quero comprar alimentos",
                                color: .green
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                NavigationLink(destination: LoginView().environmentObject(authViewModel)) {
                    Text("Já tem uma conta? Entre aqui")
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(
                    destination: SignupView()
                        .environmentObject(sellerAuthVM)
                        .environmentObject(authViewModel),
                    isActive: $navigateToSignup
                ) { EmptyView() }
            )
        }
    }
}
