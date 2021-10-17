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
    var deleteResponse = PassthroughSubject<DeleteResponse, Error>()
    
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
                    self?.userDetailSubject.send(completion: .failure(err))
                case .finished: break
                }
            }, receiveValue: { [weak self] result in
                self?.userDetailSubject.send(result)
            })
            .store(in: &cancellables)
    }
    
    func create(user: User) {
        let postData = try? JSONEncoder().encode(user)
        utility.request(apiMethod: .createUser, httpMethod: .POST, requestBody: postData)
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
    
    func deleteUser(id: String) {
        utility.request(apiMethod: .deleteUser(id: id), httpMethod: .DELETE)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let err):
                    self?.deleteResponse.send(completion: .failure(err))
                case .finished: break
                }
            }, receiveValue: { [weak self] (result: DeleteResponse) in
                self?.deleteResponse.send(result)
            })
            .store(in: &cancellables)
    }
}
