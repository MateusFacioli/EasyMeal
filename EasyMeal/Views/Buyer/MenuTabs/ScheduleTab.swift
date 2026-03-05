//
//  ScheduleTab.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI
import MapKit
import Foundation

struct ScheduleTab: View {
    let seller: Seller
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if seller.schedules.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Horários não configurados")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Este comerciante ainda não definiu seus horários de atendimento")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 300)
                .padding()
            } else {
                // Status de funcionamento hoje
                let today = Calendar.current.component(.weekday, from: Date())
                let todaySchedule = seller.schedules.first { $0.dayOfWeek == today && $0.isActive }
                
                VStack(alignment: .leading, spacing: 12) {
                    Label {
                        Text("Funcionamento Hoje")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                    
                    if let schedule = todaySchedule {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    
                                    Text("Aberto")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.green)
                                }
                                
                                Text("\(schedule.startTime, style: .time) - \(schedule.endTime, style: .time)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                if let address = schedule.location.address {
                                    Label(address, systemImage: "location.fill")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            if schedule.isActive {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.green.opacity(0.3))
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(15)
                    } else {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                    
                                    Text("Fechado hoje")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.red)
                                }
                                
                                Text("Não há atendimento hoje")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "xmark.seal.fill")
                                .font(.largeTitle)
                                .foregroundColor(.red.opacity(0.3))
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(15)
                    }
                }
                .padding(.horizontal)
                
                // Horários da Semana
                VStack(alignment: .leading, spacing: 12) {
                    Label {
                        Text("Horários da Semana")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 8) {
                        ForEach([1, 2, 3, 4, 5, 6, 7], id: \.self) { (day: Int) in
                            if let schedule = seller.schedules.first(where: { $0.dayOfWeek == day }) {
                                WeekDayRow(
                                    dayName: schedule.dayName,
                                    hours: "\(schedule.startTime) - \(schedule.endTime)",
                                    location: schedule.location.address,
                                    isActive: schedule.isActive,
                                    isToday: day == today
                                )
                            } else {
                                WeekDayRow(
                                    dayName: getDayName(for: day),
                                    hours: "Fechado",
                                    location: nil,
                                    isActive: false,
                                    isToday: day == today
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Ações
                VStack(spacing: 12) {
                    Button(action: {
                        addToCalendar()
                    }) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Adicionar horários ao calendário")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    if let location = seller.currentLocation {
                        Button(action: {
                            openMaps(location: location)
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Ver localização no mapa")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
        }
        .padding(.vertical)
    }
    
    private func getDayName(for day: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        return dateFormatter.weekdaySymbols[day - 1]
    }
    
    private func addToCalendar() {
        // TODO: Implementar adição ao calendário nativo
        // Usar EventKit para adicionar eventos ao calendário
        print("Adicionar horários ao calendário")
    }
    
    private func openMaps(location: Location) {
        let coordinate = location.coordinate
        let url = URL(string: "maps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)")
        
        if let url = url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Fallback para Apple Maps web
            let webUrl = URL(string: "https://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)")
            if let webUrl = webUrl {
                UIApplication.shared.open(webUrl)
            }
        }
    }
}
