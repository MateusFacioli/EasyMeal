//
//  ScheduleSetupViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


class ScheduleSetupViewModel: ObservableObject {
    @Published var schedules: [Schedule] = []
    @Published var selectedDay: Int = 1
    @Published var startTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var endTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var newScheduleLocation: Location?
    @Published var isLoading = false
    
    var canAddSchedule: Bool {
        newScheduleLocation != nil && startTime < endTime
    }
    
    private let databaseService: DatabaseServiceProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService(),
         locationService: LocationServiceProtocol = LocationService()) {
        self.databaseService = databaseService
        self.locationService = locationService
    }
    
    func dayName(for dayNumber: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        return dateFormatter.weekdaySymbols[dayNumber - 1]
    }
    
    func loadSchedules() {
        guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
        
        databaseService.fetch(path: "\(Constants.FirebasePaths.sellers)/\(userId)")
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading schedules: \(error)")
                }
            } receiveValue: { [weak self] (seller: Seller) in
                self?.schedules = seller.schedules
            }
            .store(in: &cancellables)
    }
    
    func useCurrentLocationForNewSchedule() {
        locationService.getCurrentLocation()
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error getting location: \(error)")
                }
            } receiveValue: { [weak self] location in
                self?.newScheduleLocation = location
            }
            .store(in: &cancellables)
    }
    
    func addSchedule() {
        guard let location = newScheduleLocation else { return }
        
        let newSchedule = Schedule(
            id: UUID().uuidString,
            dayOfWeek: selectedDay,
            startTime: startTime,
            endTime: endTime,
            location: location,
            isActive: true
        )
        
        schedules.append(newSchedule)
        
        // Reset form
        newScheduleLocation = nil
        startTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        endTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
    }
    
    func deleteSchedule(at offsets: IndexSet) {
        schedules.remove(atOffsets: offsets)
    }
    
    func saveAllSchedules() {
        guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
        
        // Converter schedules para dicionário
        let schedulesData = schedules.map { schedule in
            [
                "id": schedule.id,
                "dayOfWeek": schedule.dayOfWeek,
                "startTime": schedule.startTime.timeIntervalSince1970,
                "endTime": schedule.endTime.timeIntervalSince1970,
                "isActive": schedule.isActive,
                "location": [
                    "latitude": schedule.location.latitude,
                    "longitude": schedule.location.longitude,
                    "address": schedule.location.address ?? "",
                    "placeName": schedule.location.placeName ?? ""
                ] as [String: Any]
            ] as [String: Any]
        }
        
        databaseService.update(path: "\(Constants.FirebasePaths.sellers)/\(userId)", data: ["schedules": schedulesData])
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error saving schedules: \(error)")
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name("SchedulesSaved"), object: nil)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}