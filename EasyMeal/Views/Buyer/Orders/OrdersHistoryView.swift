//
//  OrdersHistoryView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI

struct OrdersHistoryView: View {
    @StateObject private var viewModel = OrdersHistoryViewModel()
    @State private var selectedFilter: OrderHistoryFilter = .all
    @State private var selectedOrder: Order? = nil
    @State private var showOrderDetail = false
    @State private var showReorderConfirmation = false
    @State private var orderToReorder: Order? = nil
    
    var filteredOrders: [Order] {
        let orders = viewModel.orders
        
        switch selectedFilter {
        case .all:
            return orders
        case .pending:
            return orders.filter { $0.status == .pending || $0.status == .confirmed || $0.status == .preparing }
        case .completed:
            return orders.filter { $0.status == .delivered }
        case .cancelled:
            return orders.filter { $0.status == .cancelled }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filtros
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(OrderHistoryFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.title,
                            count: countForFilter(filter),
                            isSelected: selectedFilter == filter,
                            action: { selectedFilter = filter }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .background(Color(.systemBackground))
            
            // Lista de Pedidos
            if viewModel.isLoading {
                ProgressView("Carregando pedidos...")
                    .frame(maxHeight: .infinity)
            } else if filteredOrders.isEmpty {
                EmptyOrdersView(filter: selectedFilter)
            } else {
                List {
                    ForEach(filteredOrders) { order in
                        OrderHistoryCard(order: order)
                            .onTapGesture {
                                selectedOrder = order
                                showOrderDetail = true
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if order.status == .delivered {
                                    Button {
                                        reorder(order)
                                    } label: {
                                        Label("Refazer", systemImage: "arrow.clockwise")
                                    }
                                    .tint(.blue)
                                }
                            }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Meus Pedidos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.loadOrders(refresh: true) }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .sheet(isPresented: $showOrderDetail) {
            if let order = selectedOrder {
                OrderHistoryDetailView(order: order)
            }
        }
        .alert("Refazer Pedido", isPresented: $showReorderConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Confirmar", role: .none) {
                if let order = orderToReorder {
                    confirmReorder(order)
                }
            }
        } message: {
            Text("Deseja refazer este pedido?")
        }
        .onAppear {
            viewModel.loadOrders()
        }
    }
    
    private func countForFilter(_ filter: OrderHistoryFilter) -> Int {
        let orders = viewModel.orders
        
        switch filter {
        case .all:
            return orders.count
        case .pending:
            return orders.filter { $0.status == .pending || $0.status == .confirmed || $0.status == .preparing }.count
        case .completed:
            return orders.filter { $0.status == .delivered }.count
        case .cancelled:
            return orders.filter { $0.status == .cancelled }.count
        }
    }
    
    private func reorder(_ order: Order) {
        orderToReorder = order
        showReorderConfirmation = true
    }
    
    private func confirmReorder(_ order: Order) {
        // Implementar lógica para refazer pedido
        viewModel.reorder(order: order)
    }
}

// MARK: - Order History Detail View
struct OrderHistoryDetailView: View {
    let order: Order
    @Environment(\.presentationMode) var presentationMode
    @State private var showRateSeller = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Text(order.sellerName ?? "Comerciante")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Pedido #\(order.id.prefix(8))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(order.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    // Status
                    VStack(spacing: 10) {
                        Text(order.status.rawValue)
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(statusColor(for: order.status))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        
                        if order.status == .delivered {
                            Text("Entregue em \(order.createdAt, style: .date)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Itens do Pedido
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Itens do Pedido")
                            .font(.headline)
                        
                        ForEach(order.items) { item in
                            OrderItemRow(item: item)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(order.formattedTotal)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Informações do Pedido
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Informações do Pedido")
                            .font(.headline)
                        
                        InfoDetailRow(title: "Método de Pagamento", value: order.paymentMethod ?? "Não informado")
                        InfoDetailRow(title: "Observações", value: order.notes ?? "Nenhuma")
                        
                        if let estimatedTime = order.estimatedDeliveryTime {
                            InfoDetailRow(title: "Tempo Estimado", value: "\(estimatedTime) min")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Ações
                    if order.status == .delivered {
                        Button(action: { showRateSeller = true }) {
                            Text("Avaliar Compra")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    if order.status == .ready || order.status == .preparing {
                        Button(action: { /* Ver localização do seller */ }) {
                            Text("Ver Localização")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Fechar") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showRateSeller) {
                RateOrderView(order: order)
            }
        }
    }
    
    private func statusColor(for status: OrderStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .preparing: return .purple
        case .ready: return .green
        case .delivered: return .gray
        case .cancelled: return .red
        }
    }
}

struct InfoDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Rate Order View
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

// MARK: - Enums
enum OrderHistoryFilter: String, CaseIterable {
    case all = "Todos"
    case pending = "Em Andamento"
    case completed = "Concluídos"
    case cancelled = "Cancelados"
    
    var title: String {
        return self.rawValue
    }
}

// MARK: - Extensão para Order
extension Order {
    var sellerName: String? {
        // Em uma implementação real, você buscaria o nome do seller pelo sellerId
        return nil
    }
    
    var estimatedDeliveryTime: Int? {
        // Em uma implementação real, você calcularia com base nos itens
        return 30
    }
}
