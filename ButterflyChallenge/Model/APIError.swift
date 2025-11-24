//
//  APIError.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

// MARK: - Errors

enum MoviesDatasourceError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case serverError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "error.invalid_url".localized()
        case .invalidResponse:
            return "error.invalid_response".localized()
        case .unauthorized:
            return "error.unauthorized".localized()
        case .notFound:
            return "error.not_found".localized()
        case .serverError(let statusCode):
            return "error.server_error".localized(with: statusCode)
        case .decodingError(let error):
            return "error.decoding_error".localized(with: error.localizedDescription)
        case .networkError(let error):
            return "error.network_error".localized(with: error.localizedDescription)
        }
    }
}
