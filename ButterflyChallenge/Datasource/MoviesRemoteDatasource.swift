//
//  MoviesRemoteDatasource.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

// MARK: - Protocol

protocol MoviesRemoteDatasource {
    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponse
    func getMovieDetail(movieId: Int) async throws -> MovieDetail
}

// MARK: - Implementation

final class MoviesRemoteDatasourceImpl: MoviesRemoteDatasource {
    private let accessToken: String
    private let session: URLSession
    
    init(accessToken: String, session: URLSession = .shared) {
        self.accessToken = accessToken
        self.session = session
    }
    
    func searchMovies(query: String, page: Int = 1) async throws -> MovieSearchResponse {
        guard var urlComponents = URLComponents(string: "\(Constants.API.searchMovie)") else {
            throw MoviesDatasourceError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        guard let url = urlComponents.url else {
            throw MoviesDatasourceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MoviesDatasourceError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    let movieResponse = try decoder.decode(MovieSearchResponse.self, from: data)
                    return movieResponse
                } catch {
                    throw MoviesDatasourceError.decodingError(error)
                }
            case 401:
                throw MoviesDatasourceError.unauthorized
            default:
                throw MoviesDatasourceError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch let error as MoviesDatasourceError {
            throw error
        } catch {
            throw MoviesDatasourceError.networkError(error)
        }
    }
    
    func getMovieDetail(movieId: Int) async throws -> MovieDetail {
        let url = URL(string: "\(Constants.API.movieDetail)/\(movieId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MoviesDatasourceError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    let movieDetail = try decoder.decode(MovieDetail.self, from: data)
                    return movieDetail
                } catch {
                    throw MoviesDatasourceError.decodingError(error)
                }
            case 401:
                throw MoviesDatasourceError.unauthorized
            case 404:
                throw MoviesDatasourceError.notFound
            default:
                throw MoviesDatasourceError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch let error as MoviesDatasourceError {
            throw error
        } catch {
            throw MoviesDatasourceError.networkError(error)
        }
    }
}
