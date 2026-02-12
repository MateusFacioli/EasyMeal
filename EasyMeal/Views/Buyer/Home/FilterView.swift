struct FilterView: View {
    @Binding var radius: Double
    @Binding var showOnlyOpen: Bool
    @Binding var sortBy: SortOption
    @Environment(\.presentationMode) var presentationMode
    
    let radiusOptions: [Double] = [500, 1000, 2000, 5000, 10000]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Distância")) {
                    Picker("Raio de busca", selection: $radius) {
                        ForEach(radiusOptions, id: \.self) { value in
                            Text("\(Int(value)) metros").tag(value)
                        }
                    }
                }
                
                Section(header: Text("Filtros")) {
                    Toggle("Mostrar apenas abertos", isOn: $showOnlyOpen)
                }
                
                Section(header: Text("Ordenar por")) {
                    Picker("Ordenar", selection: $sortBy) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Aplicar") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}