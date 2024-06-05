//
//  StrengthRepository.swift
//  roome
//
//  Created by minsong kim on 5/30/24.
//

import Foundation

class StrengthRepository: StrengthRepositoryType {
    func registerStrengths(ids: [Int]) async throws {
        let URL = URLBuilder(host: APIConstants.roomeHost,
                             path: APIConstants.Profile.strengths.rawValue,
                             queries: nil)
        guard let url = URL.url else {
            throw TypeError.bindingFailure
        }
        
        let body: [String: Any] = ["ids": ids]
        let accessToken = KeyChain.read(key: .accessToken) ?? ""
        let header = ["Content-Type": "application/json",
                      "Authorization": "Bearer \(accessToken)"]
        
        let requestBuilder = RequestBuilder(url: url,
                                            method: .put,
                                            bodyJSON: body,
                                            headers: header)
        guard let request = requestBuilder.create() else {
            throw  TypeError.bindingFailure
        }
        
        _ = try await APIProvider().fetchData(from: request)
    }
}