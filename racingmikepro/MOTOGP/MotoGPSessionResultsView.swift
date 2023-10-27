import SwiftUI

struct MotoGpSessionResultsView: View {
    var eventID: String
    var categoryID: String
    var sessionID: String
    var year: String
    
    @State private var results: [MotoGpResult] = []
    
    var body: some View {
        List(results) { result in
            ResultRowView(result: result)
        }
        .onAppear(perform: fetchResults)
        .navigationBarTitle("Session Results", displayMode: .inline)
    }
    
    func fetchResults() {
        let urlString = "https://racingmike.com/api/v1.0/motogp-full-results?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9&eventid=\(eventID)&categoryid=\(categoryID)&session=\(sessionID)&year=\(year)"
        
        print("Fetching Result from: \(urlString)") // Debug Print
        
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
                let fetchedResults = try JSONDecoder().decode([MotoGpResult].self, from: data)
                DispatchQueue.main.async {
                    self.results = fetchedResults
                }
            } catch let decodingError {
                print("Decoding Error: \(decodingError)")
            }
        }
        
        task.resume()
    }
}

struct ResultRowView: View {
    var result: MotoGpResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(result.classification_position ?? 0).")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text(result.classification_rider_full_name)
                    .font(.title3)
                    .fontWeight(.medium)
                Spacer()
                Image(result.classification_rider_country_iso.lowercased())
                    .resizable()
                    .frame(width: 24, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
            .padding(.horizontal)
            
            HStack {
                Text(result.classification_team_name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Spacer()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Performance:")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                HStack(spacing: 20) {
                    Text("Laps: \(result.total_laps ?? 0)")
                    Text("Avg Speed: \(result.average_speed ?? "0")")
                    Text("Time: \(result.time ?? "0")")
                    
                }
                .font(.footnote)
                .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Info:")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                HStack(spacing: 20) {
                    Text("Gap 1st/prev: \(result.gap_first ?? "0")")
                    
                   
                }
                .font(.footnote)
                .padding(.horizontal)
            }
            
            HStack {
                Text("Points: \(result.points ?? "0")")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                Spacer()
            }
            
        }
        .padding(.vertical, 5)
                .background(Color(hex: result.current_career_step_team_color).opacity(1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: result.current_career_step_team_color), lineWidth: 1)
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
            }
}

struct MotoGpResult: Identifiable, Decodable {
    let id = UUID() // Since there is no unique id provided, we create a UUID.
    let classification_position: Int?
    let classification_rider_country_iso: String
    let classification_rider_full_name: String
    let classification_team_name: String
    let classification_rider_legacy_id: Int?
    let total_laps: Int?
    let average_speed: String?
    let gap_first: String
    let time: String?
    let record_best_lap_time: String
    let record_speed: Double?
    let record_year: Int?
    let points: String
    let year:  Int?
    let current_career_step_team_color: String
    

    

}
extension Color {
    init(hex: String) {
        let hex = hex.starts(with: "#") ? String(hex.dropFirst()) : hex
        
        var hexNumber: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&hexNumber)
        
        let red = Double((hexNumber & 0xff0000) >> 16) / 255.0
        let green = Double((hexNumber & 0x00ff00) >> 8) / 255.0
        let blue = Double(hexNumber & 0x0000ff) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}


struct MotoGpSessionResultsView_Previews: PreviewProvider {
    static var previews: some View {
        MotoGpSessionResultsView(eventID: "YOUR_EVENT_ID", categoryID: "YOUR_CATEGORY_ID", sessionID: "YOUR_SESSION_ID", year: "2023")
    }
}

