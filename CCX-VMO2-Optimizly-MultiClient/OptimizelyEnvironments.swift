//
//  OptimizelyEnvironments.swift
//  CCX-VMO2-Optimizly-MultiClient
//
//  Created by Olivier Butler on 04/09/2025.
//

import Foundation

enum OptimizelyEnvironments: String {
    case FSBucketingDevelopment = "5zz25M7Lh6XtaQJzxgFSK"
    case FSBucketingProduction = "L6pA6tFnzsCsa5YSJavGp"
    case AgentPlaygroundDevelopment = "5QdumosKsGvQST87iqPRf"
    case AgentPlaygroundProduction = "Hnw6A9PqE4aqA5KgsJbGE"

    var activeFlags: [String] {
        switch self {
        case .FSBucketingDevelopment:
            return ["background_colour"]
        case .FSBucketingProduction:
            return ["decision__flag__two", "decision_test", "background_colour"]
        case .AgentPlaygroundDevelopment:
            return ["agent_playground_feature"]
        case .AgentPlaygroundProduction:
            return ["newflag", "liam_test"]
        }
    }
}


