//
//  FormulaOneResultsView.swift
//  racingmikepro
//
//  Created by Michele on 9/29/23.
//

import Foundation
import SwiftUI


struct FormulaOneResult: Identifiable {
    var id: Int
    var raceName: String
    var winner: String
}

struct FormulaOneResultsView: View {
    
    // Sample Data
    let results: [FormulaOneResult] = [
        FormulaOneResult(id: 1, raceName: "Race 1", winner: "Driver A"),
        FormulaOneResult(id: 2, raceName: "Race 2", winner: "Driver B"),
        FormulaOneResult(id: 3, raceName: "Race 3", winner: "Driver C")
    ]
    
    var body: some View {
        List(results) { result in
            VStack(alignment: .leading) {
                Text(result.raceName)
                    .font(.headline)
                Text("Winner: \(result.winner)")
                    .font(.subheadline)
            }
        }
        .navigationBarTitle("Formula One Results", displayMode: .inline)
    }
}
