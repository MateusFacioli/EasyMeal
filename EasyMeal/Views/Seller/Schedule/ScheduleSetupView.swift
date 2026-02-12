//
//  ScheduleSetupView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import SwiftUI
import Combine
import FirebaseAuth

struct ScheduleSetupView: View {
    @StateObject private var viewModel = ScheduleSetupViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Horários Cadastrados")) {
                    if viewModel.schedules.isEmpty {
                        Text("Nenhum horário cadastrado")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(viewModel.schedules) { schedule in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(schedule.dayName)
                                        .fontWeight(.medium)
                                    Text("\(schedule.startTime, style: .time) - \(schedule.endTime, style: .time)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    if let address = schedule.location.address {
                                        Text(address)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { schedule.isActive },
                                    set: { _ in }
                                ))
                                .labelsHidden()
                            }
                        }
                        .onDelete(perform: viewModel.deleteSchedule)
                    }
                }
                
                Section(header: Text("Adicionar Novo Horário")) {
                    Picker("Dia da Semana", selection: $viewModel.selectedDay) {
                        ForEach(1...7, id: \.self) { day in
                            Text(viewModel.dayName(for: day)).tag(day)
                        }
                    }
                    
                    DatePicker("Horário Início", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                    
                    DatePicker("Horário Fim", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                    
                    Button("Usar Localização Atual") {
                        viewModel.useCurrentLocationForNewSchedule()
                    }
                    .foregroundColor(.blue)
                    
                    Button(action: viewModel.addSchedule) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Adicionar Horário")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.canAddSchedule)
                }
            }
            .navigationBarTitle("Horários de Atendimento", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Salvar") {
                    viewModel.saveAllSchedules()
                }
            )
            .onAppear {
                viewModel.loadSchedules()
            }
        }
    }
}
