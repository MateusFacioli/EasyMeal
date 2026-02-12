//
//  EmptyOrdersView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


struct EmptyOrdersView: View {
    let filter: OrderHistoryFilter
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            switch filter {
            case .all:
                VStack(spacing: 10) {
                    Text("Nenhum pedido ainda")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Faça seu primeiro pedido!")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            case .pending:
                Text("Nenhum pedido em andamento")
                    .font(.headline)
                    .foregroundColor(.gray)
            case .completed:
                Text("Nenhum pedido concluído")
                    .font(.headline)
                    .foregroundColor(.gray)
            case .cancelled:
                Text("Nenhum pedido cancelado")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            NavigationLink(destination: BuyerHomeView()) {
                Text("Fazer Pedido")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxHeight: .infinity)
    }
}
