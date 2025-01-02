import Foundation

struct Config {
    static let shared = Config()
    
    let googleMapsAPIKey: String
    let appCenterIdentifier: String?
    let moEngageAppGroup: String?
    let moEngageIdentifier: String?
    let adjustIdentifier: String?
    
    private init() {
        let scheme = Config.getCurrentScheme()
        self.googleMapsAPIKey = Config.getConfigValue(for: "GOOGLE_MAPS_API_KEY_\(scheme)")
        self.appCenterIdentifier = Config.getConfigValue(for: "APP_CENTER_IDENTIFIER_\(scheme)")
        self.moEngageAppGroup = Config.getConfigValue(for: "MOENGAGE_APP_GROUP_\(scheme)")
        self.moEngageIdentifier = Config.getConfigValue(for: "MOENGAGE_IDENTIFIER_\(scheme)")
        self.adjustIdentifier = Config.getConfigValue(for: "ADJUST_IDENTIFIER_\(scheme)")
    }
    
    private static func getConfigValue(for key: String) -> String {
        // Construct the path relative to the project directory
        if let secretsPath = Bundle.main.infoDictionary?["SCSecretsPath"] as? String,
                  FileManager.default.fileExists(atPath: secretsPath),
                  let dict = NSDictionary(contentsOfFile: secretsPath) as? [String: String], let value = dict[key] {
            print("-----Local-----")
            print(key)
            print(value)
            print("----------")
            return value
        } else if let infoDictionary = Bundle.main.infoDictionary?["Data"] as? [String: Any],
           let environmentDict = infoDictionary["Environment"] as? [String: String],
           let value = environmentDict[key] {
//            SCFileLogger.shared.write("key : \(value) ", withTag: .logout)
            print("----CI/CD------")
            print(key)
            print(value)
            print("----------")
            return value
        } else {
//            SCFileLogger.shared.write("else part \(key) Not able to fetch", withTag: .logout)
            fatalError("\(key) not set in Info.plist")
        }
    }

    private static func getCurrentScheme() -> String {
        guard let scheme = Bundle.main.infoDictionary?["CONFIG_SCHEME"] as? String else {
            fatalError("CONFIG_SCHEME not set in Info.plist")
        }
        return scheme
    }
}
