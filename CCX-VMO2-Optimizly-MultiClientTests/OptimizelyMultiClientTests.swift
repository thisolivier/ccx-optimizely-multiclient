import XCTest
import Optimizely
@testable import CCX_VMO2_Optimizly_MultiClient

final class OptimizelyMultiClientTests: XCTestCase {

    func testMultipleClientsCanBeHeldInMemory() {
        let clients = OptimizelyClientHelper.instantiateAllClients()
        XCTAssertEqual(clients.count, OptimizelyEnvironments.allCases.count)

        // Ensure objects are distinct
        let uniqueIdentifiers = Set(clients.values.map { ObjectIdentifier($0) })
        XCTAssertEqual(uniqueIdentifiers.count, clients.count)
    }

    func testDecisionsForAllFlagsAcrossEnvironments() {
        let clients = OptimizelyClientHelper.instantiateAllClients()
        let startExpectation = expectation(description: "Clients started")
        OptimizelyClientHelper.start(clients: clients) {
            startExpectation.fulfill()
        }
        wait(for: [startExpectation], timeout: 10)

        let userId = "shared_user"
        let decisions = OptimizelyClientHelper.decisionsForAllFlags(userId: userId, clients: clients)

        for (env, flagDecisions) in decisions {
            for (flag, result) in flagDecisions {
                let decision = result.0
                let supported = result.1
                print("Env: \(env) flag: \(flag) supported: \(supported) variation: \(decision.variationKey ?? \"\") enabled: \(decision.enabled)")
                if supported {
                    XCTAssertNotNil(decision.variationKey, "Expected variation for supported flag \(flag) in \(env)")
                } else {
                    XCTAssertNil(decision.variationKey, "Expected no variation for unsupported flag \(flag) in \(env)")
                    XCTAssertFalse(decision.enabled, "Expected disabled decision for unsupported flag \(flag) in \(env)")
                }
            }
        }
    }

    func testChangingUserIdChangesBucketingOnlyForThatClient() {
        let clients = OptimizelyClientHelper.instantiateAllClients()
        let startExpectation = expectation(description: "Clients started")
        OptimizelyClientHelper.start(clients: clients) {
            startExpectation.fulfill()
        }
        wait(for: [startExpectation], timeout: 10)

        let initialUserId = "1000"
        let initialDecisions = OptimizelyClientHelper.decisions(for: initialUserId, clients: clients)

        guard let envToChange = OptimizelyEnvironments.allCases.first else {
            XCTFail("No environments available")
            return
        }

        var newDecisions: [OptimizelyEnvironments: [String: OptimizelyDecision]] = [:]
        for (env, client) in clients {
            let userId = env == envToChange ? "2000" : initialUserId
            let user = client.createUserContext(userId: userId)
            var envResults: [String: OptimizelyDecision] = [:]
            for flag in env.activeFlags {
                envResults[flag] = user.decide(key: flag)
            }
            newDecisions[env] = envResults
        }

        for env in OptimizelyEnvironments.allCases {
            guard let oldDecision = initialDecisions[env]?.values.first,
                  let newDecision = newDecisions[env]?.values.first else {
                XCTFail("Missing decisions")
                continue
            }
            if env == envToChange {
                XCTAssertNotEqual(oldDecision.variationKey, newDecision.variationKey, "Expected different variation for \(env)")
            } else {
                XCTAssertEqual(oldDecision.variationKey, newDecision.variationKey, "Expected same variation for \(env)")
            }
        }
    }
}
