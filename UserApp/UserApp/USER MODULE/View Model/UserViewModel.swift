//
//  UserViewModel.swift
//  CNSApp
//
//  Created by Shubham Joshi on 10/10/21.
//

import Foundation
import Combine

class UserViewModel: ObservableObject {
    var userSubject = PassthroughSubject<Users, Error>()
    var userDetailSubject = PassthroughSubject<UserDetail, Error>()
    
    private let utility = HTTPUtility()
    private var cancellables = Set<AnyCancellable>()
   
    func getUsers(page: Int, limit: Int) {
        let param = ["page": "\(page)", "limit": "\(limit)"]
        utility.request(apiMethod: .user, parameter: param)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let err):
                    self?.userSubject.send(completion: .failure(err))
                case .finished: break
                }
            }, receiveValue: { [weak self] result in
                self?.userSubject.send(result)
            })
            .store(in: &cancellables)
    }
    
    func getUser(by id: String) {
        utility.request(apiMethod: .userBy(id: id))
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let err):
                    self?.userSubject.send(completion: .failure(err))
                case .finished: break
                }
            }, receiveValue: { [weak self] result in
                self?.userDetailSubject.send(result)
            })
            .store(in: &cancellables)
    }
}
