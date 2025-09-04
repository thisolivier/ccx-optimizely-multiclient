import Foundation
import Optimizely

enum LogLevel: String {
    case warning = "⚠️ Warning"
    case error = "❌ Error"
}

final class Logger {
    static let shared = Logger()
    private(set) var warnings: [String] = []
    private(set) var errors: [String] = []

    private init() {}

    private func log(_ level: LogLevel, _ message: String) {
        switch level {
        case .warning:
            warnings.append(message)
        case .error:
            errors.append(message)
        }
        print("\(level.rawValue): \(message)")
    }

    func warning(_ message: String) {
        log(.warning, message)
    }

    func error(_ message: String) {
        log(.error, message)
    }
}

final class OptimizelyLoggerAdapter: OptimizelyLogger {
    func log(level: OptimizelyLogLevel, message: String) {
        switch level {
        case .warning:
            Logger.shared.warning(message)
        case .error:
            Logger.shared.error(message)
        default:
            break
        }
    }
}

