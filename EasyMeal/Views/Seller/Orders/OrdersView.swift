//
//  OrdersView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI
import Combine

struct OrdersView: View {
    @StateObject private var viewModel = OrdersViewModel()
    @State private var selectedFilter: OrderFilter = .all
    @State private var showOrderDetail = false
    @State private var selectedOrder: Order?
    
    var filteredOrders: [Order] {
        switch selectedFilter {
        case .all:
            return viewModel.orders
        case .pending:
            return viewModel.orders.filter { $0.status == .pending }
        case .confirmed:
            return viewModel.orders.filter { $0.status == .confirmed }
        case .preparing:
            return viewModel.orders.filter { $0.status == .preparing }
        case .ready:
            return viewModel.orders.filter { $0.status == .ready }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filtros
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(OrderFilter.allCases, id: \.self) { filter in
                        FilterButton(
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
            if filteredOrders.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Nenhum pedido encontrado")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    if selectedFilter != .all {
                        Button("Mostrar Todos") {
                            selectedFilter = .all
                        }
                        .foregroundColor(.blue)
                    }
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredOrders) { order in
                        OrderCard(order: order)
                            .onTapGesture {
                                selectedOrder = order
                                showOrderDetail = true
                            }
                            .swipeActions(edge: .trailing) {
                                if order.status == .pending {
                                    Button {
                                        confirmOrder(order)
                                    } label: {
                                        Label("Confirmar", systemImage: "checkmark.circle")
                                    }
                                    .tint(.green)
                                    
                                    Button {
                                        cancelOrder(order)
                                    } label: {
                                        Label("Cancelar", systemImage: "xmark.circle")
                                    }
                                    .tint(.red)
                                }
                                
                                if order.status == .confirmed {
                                    Button {
                                        startPreparing(order)
                                    } label: {
                                        Label("Preparar", systemImage: "timer")
                                    }
                                    .tint(.orange)
                                }
                                
                                if order.status == .preparing {
                                    Button {
                                        markAsReady(order)
                                    } label: {
                                        Label("Pronto", systemImage: "checkmark")
                                    }
                                    .tint(.blue)
                                }
                            }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Pedidos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { viewModel.loadOrders(refresh: true) }) {
                        Label("Atualizar", systemImage: "arrow.clockwise")
                    }
                    
                    Button(action: {}) {
                        Label("Relatório", systemImage: "chart.bar.doc.horizontal")
                    }
                    
                    Button(action: {}) {
                        Label("Filtrar por Data", systemImage: "calendar")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showOrderDetail) {
            if let order = selectedOrder {
                OrderDetailView(order: order)
            }
        }
        .onAppear {
            viewModel.loadOrders()
        }
    }
    
    private func countForFilter(_ filter: OrderFilter) -> Int {
        switch filter {
        case .all:
            return viewModel.orders.count
        case .pending:
            return viewModel.orders.filter { $0.status == .pending }.count
        case .confirmed:
            return viewModel.orders.filter { $0.status == .confirmed }.count
        case .preparing:
            return viewModel.orders.filter { $0.status == .preparing }.count
        case .ready:
            return viewModel.orders.filter { $0.status == .ready }.count
        }
    }
    
    private func confirmOrder(_ order: Order) {
        viewModel.updateOrderStatus(order.id, to: .confirmed)
    }
    
    private func cancelOrder(_ order: Order) {
        viewModel.updateOrderStatus(order.id, to: .cancelled)
    }
    
    private func startPreparing(_ order: Order) {
        viewModel.updateOrderStatus(order.id, to: .preparing)
    }
    
    private func markAsReady(_ order: Order) {
        viewModel.updateOrderStatus(order.id, to: .ready)
    }
}
