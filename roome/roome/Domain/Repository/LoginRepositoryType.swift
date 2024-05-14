//
//  LoginRepositoryType.swift
//  roome
//
//  Created by minsong kim on 5/14/24.
//

import Foundation

protocol LoginRepositoryType {
//    private let loginRepository: LoginRepository
    
    func requestLogin(body json: [String: Any], decodedDataType: LoginDTO.Type) async -> LoginDTO?
}
