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
    private let utility = HTTPUtility()
    private var cancellables = Set<AnyCancellable>()
   
    func getData() {
        utility.request(apiMethod: .user)
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
}
