//
//  SecretsManager.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

enum SecretsManager {
    private static var secrets: [String: Any]? = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            print(">>> Warning: Secrets.plist not found or could not be loaded")
            return nil
        }
        return plist
    }()
    
    static func getValue(for key: String) -> String? {
        return secrets?[key] as? String
    }
    
    static var apiAccessToken: String? {
        return getValue(for: "APIAccessToken")
    }
}
