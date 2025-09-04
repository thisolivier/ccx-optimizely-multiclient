//
//  ContentView.swift
//  CCX-VMO2-Optimizly-MultiClient
//
//  Created by Olivier Butler on 04/09/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var userId: String = "1000"

    var body: some View {
        VStack(spacing: 16) {
            Text("Current User ID: \(userId)")
            Button("Run Flag Checks") {
                OptimizelyClientHelper.logAllFlagDecisions(userId: userId)
            }
            Button("Change User ID") {
                userId = String(Int.random(in: 1000...9999))
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
