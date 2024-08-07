//
//  APIProvider.swift
//  roome
//
//  Created by minsong kim on 5/13/24.
//

import Foundation

class APIProvider {
    func fetchData(from request: URLRequest) async throws -> Data {
        //TODO: - 인터넷 연결되어 있는지 체크
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noResponse
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            return data
        } else if httpResponse.statusCode == 400 {
            throw NetworkError.failureCode(try fetchErrorData(data))
        } else if httpResponse.statusCode == 401 {
            let newData = try await retryWithUpdateToken(request: request)
            return newData
        } else {
            print(httpResponse.statusCode)
            throw NetworkError.invalidStatus(httpResponse.statusCode)
        }
    }
    
    func fetchURLData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noResponse
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            return data
        } else if httpResponse.statusCode == 400 {
            throw NetworkError.failureCode(try fetchErrorData(data))
        } else {
            print(httpResponse.statusCode)
            throw NetworkError.invalidStatus(httpResponse.statusCode)
        }
    }
    
    func fetchDecodedData<T: Decodable>(type: T.Type, from request: URLRequest) async throws -> T {
        let data = try await fetchData(from: request)
        let jsonData = try JSONDecoder().decode(type, from: data)
        
        return jsonData
    }
    
    func fetchErrorData(_ data: Data) throws -> ErrorDTO {
        let jsonData = try JSONDecoder().decode(ErrorDTO.self, from: data)
        
        return jsonData
    }
}

extension APIProvider {
    private func retry(request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noResponse
        }
        if (200...299).contains(httpResponse.statusCode) {
            print("200")
            return data
        } else {
            print(httpResponse.statusCode)
            throw NetworkError.invalidStatus(httpResponse.statusCode)
        }
    }
    
    private func refreshAccessToken() async throws -> LoginDTO? {
        let userURL = URLBuilder(host: APIConstants.roomeHost,
                                 path: APIConstants.Auth.token.name,
                                 queries: nil)
        guard let url = userURL.url else {
            return nil
        }
        
        let refreshToken = KeyChain.read(key: .refreshToken) ?? ""
        let body: [String: Any] = ["refreshToken": refreshToken]
        let requestBuilder = RequestBuilder(url: url, method: .post, bodyJSON: body)
        guard let request = requestBuilder.create() else {
            return nil
        }
        
        let data = try await retry(request: request)
        
        let jsonData = try JSONDecoder().decode(LoginDTO.self, from: data)
        
        return jsonData
    }
    
    private func updateToken(request: URLRequest) async throws -> URLRequest {
        guard let tokens = try await refreshAccessToken() else {
            throw NetworkError.noResponse
        }
        
        KeyChain.update(key: .accessToken, data: tokens.data.accessToken)
        KeyChain.update(key: .refreshToken, data: tokens.data.refreshToken)
        
        var newRequest = request
        newRequest.setValue("Bearer \(tokens.data.accessToken)", forHTTPHeaderField: "Authorization")
        
        return newRequest
    }
    
    private func retryWithUpdateToken(request: URLRequest) async throws -> Data {
        let newRequest = try await updateToken(request: request)
        let data = try await retry(request: newRequest)
        
        return data
    }
}
