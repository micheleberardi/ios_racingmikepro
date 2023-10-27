import SwiftUI

struct MotoGPResultsView: View {
    // Define your properties here
    let years = Array(2000...2023).map { String($0) }
    @State private var selectedYear = "2023"
    @State private var events: [MotoGPEvent] = []
    @State private var selectedEvent: MotoGPEvent?
    @State private var categories: [MotoGPCategory] = []
    @State private var selectedCategory: MotoGPCategory?

    @State private var sessions: [MotoGPSession] = []
    @State private var selectedSession: MotoGPSession?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Year")) {
                    Picker("Select Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedYear) { newValue in
                        fetchEvents(for: newValue)
                        }
                    }
                
                Section(header: Text("Select Event")) {
                    Picker("Select Event", selection: $selectedEvent) {
                        ForEach(events, id: \.self) { event in
                            Text(event.name).tag(event)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedEvent) { newValue in
                        if let newEvent = newValue {
                            fetchCategories(for: newEvent.id)
                        } else {
                            categories = [] // Clear categories if no event is selected
                            }
                        }
                    .disabled(events.isEmpty)
                    }
                
                Section(header: Text("Select Category")) {
                    Picker("Select Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.name).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .disabled(categories.isEmpty)
                    }
                
                Section(header: Text("Select Session")) {
                    Picker("Select Session", selection: $selectedSession) {
                        ForEach(sessions, id: \.self) { session in
                            Text(session.type).tag(session)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .disabled(sessions.isEmpty)
                    }
                
                    if let selectedSession = selectedSession, let selectedEvent = selectedEvent, let selectedCategory = selectedCategory {
                        NavigationLink(destination: MotoGpSessionResultsView(eventID: selectedEvent.id, categoryID: selectedCategory.id, sessionID: selectedSession.id, year: selectedYear)) {
                            Text("Show Results")
                        }
                    }
                }
                .navigationBarTitle("MotoGP Results", displayMode: .inline)
        }
        .onAppear {
            fetchEvents(for: selectedYear)
        }
    }
                    
    
    func fetchEvents(for year: String) {
        let urlString = "https://racingmike.com/api/v1.0/motogp-events?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9&year=\(year)"
        print("Fetching events from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let fetchedEvents = try JSONDecoder().decode([MotoGPEvent].self, from: data)
                DispatchQueue.main.async {
                    self.events = fetchedEvents
                    if let lastEvent = fetchedEvents.first {
                        self.selectedEvent = lastEvent
                        self.fetchCategories(for: lastEvent.id)
                    }
                }
            } catch let decodingError {
                print("Decoding Error: \(decodingError)")
            }
        }
        
        task.resume()
    }

    func fetchCategories(for eventId: String) {
        let urlString = "https://racingmike.com/api/v1.0/motogp-category?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9&year=\(selectedYear)&eventid=\(eventId)"
        print("Fetching categories from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received for categories")
                return
            }
            
            do {
                let fetchedCategories = try JSONDecoder().decode([MotoGPCategory].self, from: data)
                DispatchQueue.main.async {
                    self.categories = fetchedCategories
                    if let motoGPCategory = fetchedCategories.first(where: { $0.name == "MotoGP™" }) {
                        self.selectedCategory = motoGPCategory
                        self.fetchSessions()
                    } else if let firstCategory = fetchedCategories.first {
                        self.selectedCategory = firstCategory
                        self.fetchSessions()
                    }
                }
            } catch let decodingError {
                print("Decoding Error: \(decodingError)")
            }

        }
        .resume()
    }
    
    func fetchSessions() {
        guard let selectedEventId = selectedEvent?.id, let selectedCategoryId = selectedCategory?.id else {
            return
        }
        
        let urlString = "https://racingmike.com/api/v1.0/motogp-sessions?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9&year=\(selectedYear)&eventid=\(selectedEventId)&categoryid=\(selectedCategoryId)"
        print("Fetching sessions from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let fetchedSessions = try JSONDecoder().decode([MotoGPSession].self, from: data)
                DispatchQueue.main.async {
                    self.sessions = fetchedSessions
                    if let raceSession = fetchedSessions.first(where: { $0.type.lowercased() == "rac" }) {
                        self.selectedSession = raceSession
                    } else if let firstSession = fetchedSessions.first {
                        self.selectedSession = firstSession
                    }
                }
            } catch let decodingError {
                print("Decoding Error: \(decodingError)")
            }
        }
        .resume()
    }
}

struct MotoGPResultsView_Previews: PreviewProvider {
    static var previews: some View {
        MotoGPResultsView()
    }
}

struct MotoGPEvent: Identifiable, Decodable {
    let id: String
    let name: String
}

struct MotoGPCategory: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
}

struct MotoGPSession: Identifiable, Decodable, Hashable {
    let id: String
    let type: String
}

