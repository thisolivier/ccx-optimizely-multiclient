//
//  ContentView.swift
//  CCX-VMO2-Optimizly-MultiClient
//
//  Created by Olivier Butler on 04/09/2025.
//

import SwiftUI
import Optimizely

struct ContentView: View {

    func dummyOptimizelySetup() {
        let optimizelyClient = OptimizelyClient(sdkKey: "YOUR_SDK_KEY", defaultLogLevel: .error)
        optimizelyClient.start { result in
            switch result {
            case .success(let datafile):
                for _ in 0...9 {
                    let userId = String(Int.random(in: 1000...9999))
                    let user = optimizelyClient.createUserContext(userId: userId)
                    let decision = user.decide(key: "product_sort")
                    // did decision fail with a critical error?
                    if decision.variationKey == nil || decision.variationKey == "" {
                        print("decision error: \(decision.reasons)" )
                    }

                    // --------------------------------
                    // Mock what the users sees with print statements (in production, use flag variables to implement feature configuration)
                    // --------------------------------
                    print("\n\nFlag \(decision.enabled ? "on" : "off"). User number \(user.userId) saw flag variation: \(decision.variationKey ?? "") as part of flag rule: \(decision.ruleKey ?? "")")
                }
            case .failure(_):
                print("Optimizely client invalid. Verify in Settings>Environments that you used the primary environment's SDK key")
            }
        }
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
