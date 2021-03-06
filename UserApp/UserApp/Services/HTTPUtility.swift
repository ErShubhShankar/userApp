//
//  HTTPUtility.swift
//  CNSApp
//
//  Created by Shubham Joshi on 05/10/21.
//

import Foundation
import Combine

final class HTTPUtility {
    private var cancellables = Set<AnyCancellable>()
    typealias NetworkResponse = (data: Data, response: URLResponse)
    
    private func getURLRequest(apiMethod: APIMethods, parameteres: [String: String] = [:], requestBody: Data? = nil) throws -> URLRequest {
        var component = URLComponents()
        component.scheme = "https"
        component.host = Constant.baseURL.rawValue
        component.path = Constant.urlPath.rawValue+apiMethod.string
        
        if apiMethod.httpMethod == "GET" {
            var arrQueryItems: [URLQueryItem] = []
            for (key, value) in parameteres {
                let queryItem = URLQueryItem(name: key, value: value)
                arrQueryItems.append(queryItem)
            }
            component.queryItems = arrQueryItems.isEmpty ? nil : arrQueryItems
        }
        guard let completeURL = component.url else {
            throw NetworkError.invalidURL
        }
        let headers = ["app-id": Constant.appID.rawValue]
        var request = URLRequest(url: completeURL)
        request.allHTTPHeaderFields = headers
        request.httpMethod = apiMethod.httpMethod
        request.cachePolicy = .reloadIgnoringCacheData
        request.timeoutInterval = TimeInterval(20)
        if requestBody != nil, apiMethod.httpMethod != "GET" {
            request.httpBody = requestBody
        }
        return request
    }
    
    func request<T: Decodable>(apiMethod: APIMethods, parameteres: [String: String] = [:], requestBody: Data? = nil) async throws -> T {
        let request = try getURLRequest(apiMethod: apiMethod, parameteres: parameteres, requestBody: requestBody)
        let response: NetworkResponse = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: response.data)
    }
    
    func request<T: Codable>(apiMethod: APIMethods, httpMethod: HTTPMethod = .GET, parameter: [String: String] = [:],
                             requestBody: Data? = nil) -> Future<T, Error> {
        return Future<T, Error> { [weak self] promise in
            var component = URLComponents()
            component.scheme = "https"
            component.host = Constant.baseURL.rawValue
            component.path = Constant.urlPath.rawValue+apiMethod.string
            if httpMethod == .GET {
                var arrQueryItems: [URLQueryItem] = []
                for (key, value) in parameter {
                    let queryItem = URLQueryItem(name: key, value: value)
                    arrQueryItems.append(queryItem)
                }
                component.queryItems = arrQueryItems.isEmpty ? nil : arrQueryItems
            }
            
            guard let completeURL = component.url else {
                return promise(.failure(NetworkError.invalidURL))
            }
            let headers = ["app-id": Constant.appID.rawValue]
            var request = URLRequest(url: completeURL)
            request.allHTTPHeaderFields = headers
            request.httpMethod = httpMethod.rawValue
            request.cachePolicy = .reloadIgnoringCacheData
            request.timeoutInterval = TimeInterval(20)
            if requestBody != nil, httpMethod != .GET {
                request.httpBody = requestBody
            }

            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    let jsonResponse = String(data: data, encoding: .utf8) ?? ""
                    print("******* RESPONSE ******** \n", jsonResponse)
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw NetworkError.responseError
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { (completion) in
                    if case let .failure(error) = completion {
                        switch error {
                        case let decodingError as DecodingError:
                            self?.printDecodingError(error: decodingError)
                            promise(.failure(decodingError))
                        case let apiError as NetworkError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(NetworkError.unknown))
                        }
                    }
                }, receiveValue: {
                    promise(.success($0))
                })
                .store(in: &self!.cancellables)
        }
    }
    
    // MARK: - DECODER HELPER
    private func printDecodingError(error: DecodingError) {
        switch error {
        case .typeMismatch(let type, let context):
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        case .valueNotFound(let value, let context):
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        case .keyNotFound(let key, let context):
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        case .dataCorrupted(let context):
            print(context)
        @unknown default:
            print("Error in decoding -> \(error.localizedDescription)")
        }
    }
}
