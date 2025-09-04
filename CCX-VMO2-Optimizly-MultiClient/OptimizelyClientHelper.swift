import Foundation
import Optimizely

struct OptimizelyClientHelper {
    static func instantiateAllClients() -> [OptimizelyEnvironments: OptimizelyClient] {
        var clients: [OptimizelyEnvironments: OptimizelyClient] = [:]
        for env in OptimizelyEnvironments.allCases {
            let logger = OptimizelyLoggerAdapter()
            let client = OptimizelyClient(sdkKey: env.rawValue, logger: logger, defaultLogLevel: .warning)
            clients[env] = client
        }
        return clients
    }

    static func start(clients: [OptimizelyEnvironments: OptimizelyClient], completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for (env, client) in clients {
            group.enter()
            client.start { result in
                if case let .failure(error) = result {
                    Logger.shared.error("Failed to start client for \(env): \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion()
        }
    }

    static func decisions(for userId: String, clients: [OptimizelyEnvironments: OptimizelyClient]) -> [OptimizelyEnvironments: [String: OptimizelyDecision]] {
        var results: [OptimizelyEnvironments: [String: OptimizelyDecision]] = [:]
        for (env, client) in clients {
            var envResults: [String: OptimizelyDecision] = [:]
            let user = client.createUserContext(userId: userId)
            for flag in env.activeFlags {
                envResults[flag] = user.decide(key: flag)
            }
            results[env] = envResults
        }
        return results
    }

    static func flagEnvironmentMap() -> [String: [OptimizelyEnvironments]] {
        var map: [String: [OptimizelyEnvironments]] = [:]
        for env in OptimizelyEnvironments.allCases {
            for flag in env.activeFlags {
                map[flag, default: []].append(env)
            }
        }
        return map
    }

    static func decisionsForAllFlags(userId: String, clients: [OptimizelyEnvironments: OptimizelyClient]) -> [OptimizelyEnvironments: [String: (OptimizelyDecision, Bool)]] {
        let flagMap = flagEnvironmentMap()
        var results: [OptimizelyEnvironments: [String: (OptimizelyDecision, Bool)]] = [:]
        let allFlags = Array(flagMap.keys)
        for (env, client) in clients {
            var envResults: [String: (OptimizelyDecision, Bool)] = [:]
            let user = client.createUserContext(userId: userId)
            for flag in allFlags {
                let decision = user.decide(key: flag)
                let supported = env.activeFlags.contains(flag)
                envResults[flag] = (decision, supported)
                if !supported {
                    Logger.shared.warning("Flag \(flag) is not supported in \(env)")
                }
                print("Env: \(env) Flag: \(flag) Supported: \(supported) Variation: \(decision.variationKey ?? \"\") Enabled: \(decision.enabled)")
            }
            results[env] = envResults
        }
        return results
    }

    static func logAllFlagDecisions(userId: String) {
        let clients = instantiateAllClients()
        start(clients: clients) {
            _ = decisionsForAllFlags(userId: userId, clients: clients)
        }
    }
}
