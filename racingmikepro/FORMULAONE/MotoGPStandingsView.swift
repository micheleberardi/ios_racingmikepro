import SwiftUI

enum MotoGPStandingsType: String, CaseIterable, Identifiable {
    case riders = "Riders"
    case team = "Team"

    var id: String { rawValue }
}

struct MotoGPStandingsView: View {
    let years = Array(1951...2023).map { String($0) }
    @State private var selectedStandingsType = MotoGPStandingsType.riders
    @State private var selectedYear: String = "2023"
    @State private var categories: [Category] = []
    @State private var selectedCategory: Category?
    @State private var standings: [RiderStanding] = []

    var body: some View {
        VStack {
            Picker("Select Standings Type", selection: $selectedStandingsType) {
                ForEach(MotoGPStandingsType.allCases) { standingsType in
                    Text(standingsType.rawValue).tag(standingsType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedStandingsType == .riders {
                Picker("Select Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(year).tag(year)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .onChange(of: selectedYear) { _ in
                    fetchCategories()
                }

                if !categories.isEmpty {
                    Picker("Select Category", selection: $selectedCategory) {
                        ForEach(categories) { category in
                            Text(category.name).tag(Optional(category))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .onChange(of: selectedCategory) { newValue in
                        if let category = newValue {
                            fetchRiderStandings(for: category.id)
                        }
                    }
                }

                // Display the fetched rider standings
                List(standings) { standing in
                    VStack(alignment: .leading) {
                        Text("\(standing.classification_position ?? 0). \(standing.classification_rider_full_name) (\(standing.classification_rider_country_iso ?? ""))")
                            .font(.headline)
                        
                        Text("Team: \(standing.classification_constructor_name ?? "")")
                        
                        Text("Points: \(String(standing.classification_points_id ?? 0))")
                    }
                    .padding(.vertical, 4)


                }
            }
            // You can add similar logic for Team if needed
        }
        .navigationBarTitle("MotoGP Standings", displayMode: .inline)
        .onAppear {
            fetchCategories()
        }
    }

    
    func fetchCategories() {
        let urlString = "https://racingmike.com/api/v1.0/motogp-category?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9&year=\(selectedYear)"
        
        print("Fetching from URL: \(urlString)")  // Print the URL

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
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

            print(String(data: data, encoding: .utf8) ?? "")  // Print the result data as string

            do {
                let fetchedCategories = try JSONDecoder().decode([Category].self, from: data)
                DispatchQueue.main.async {
                    self.categories = fetchedCategories
                    if let motogpCategory = fetchedCategories.first(where: { $0.name == "MotoGP" }) {
                        self.selectedCategory = motogpCategory
                        fetchRiderStandings(for: motogpCategory.id)
                    }
                }
            } catch let decodingError {
                print("Decoding Error: \(decodingError)")
            }
        }
        .resume()
    }

    func fetchRiderStandings(for categoryId: String) {
        let urlString = "https://racingmike.com/api/v1.0/motogp-world-standing-riders?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9&year=\(selectedYear)&categoryid=\(categoryId)"
        
        print("Fetching from URL: \(urlString)")  // Print the URL

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching rider standings: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received for rider standings")
                return
            }

            print(String(data: data, encoding: .utf8) ?? "")  // Print the result data as string

            do {
                let fetchedStandings = try JSONDecoder().decode([RiderStanding].self, from: data)
                DispatchQueue.main.async {
                    self.standings = fetchedStandings
                }
            } catch let decodingError {
                print("Decoding Error: \(decodingError)")
            }
        }
        .resume()
    }
}

struct Category: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
}

struct RiderStanding: Identifiable, Decodable, Hashable {
    let classification_points_id: Int?
    let classification_position: Int?
    let classification_rider_full_name: String
    let classification_rider_country_iso: String
    let classification_constructor_name: String?

    // Since we don't have a unique 'id' from the provided JSON structure, we can use the position as the ID
    var id: Int {
        classification_position ?? 0 // Provide a default value if position is nil
    }
}


struct MotoGPStandingsView_Previews: PreviewProvider {
    static var previews: some View {
        MotoGPStandingsView()
    }
}


