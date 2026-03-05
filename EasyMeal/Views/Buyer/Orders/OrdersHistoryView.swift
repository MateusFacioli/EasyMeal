//
//  OrdersHistoryView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI
import Combine

struct OrdersHistoryView: View {
    @StateObject private var viewModel = OrdersHistoryViewModel()
    @State private var selectedFilter: OrderHistoryFilter = .all
    @State private var selectedOrder: OrderModel? = nil
    @State private var showOrderDetail = false
    @State private var showReorderConfirmation = false
    @State private var orderToReorder: OrderModel? = nil
    
    var filteredOrders: [OrderModel] {
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
    
    private func reorder(_ order: OrderModel) {
        orderToReorder = order
        showReorderConfirmation = true
    }
    
    private func confirmReorder(_ order: OrderModel) {
        // Implementar lógica para refazer pedido
        viewModel.reorder(order: order)
    }
}
