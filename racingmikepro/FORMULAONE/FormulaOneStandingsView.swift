//
//  FormulaOneStandingsView.swift
//  racingmikepro
//
//  Created by Michele on 9/29/23.
//

import Foundation
import SwiftUI


struct FormulaOneStanding: Identifiable {
    var id: Int
    var driverName: String
    var points: Int
    var team: String
}

struct FormulaOneStandingsView: View {
    
    // Sample Data
    let standings: [FormulaOneStanding] = [
        FormulaOneStanding(id: 1, driverName: "Driver A", points: 150, team: "Team 1"),
        FormulaOneStanding(id: 2, driverName: "Driver B", points: 135, team: "Team 2"),
        FormulaOneStanding(id: 3, driverName: "Driver C", points: 120, team: "Team 3")
    ]
    
    var body: some View {
        List(standings) { standing in
            HStack {
                VStack(alignment: .leading) {
                    Text(standing.driverName)
                        .font(.headline)
                    Text(standing.team)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(standing.points) pts")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .padding(.vertical, 5)
        }
        .navigationBarTitle("Formula One Standings", displayMode: .inline)
    }
}

