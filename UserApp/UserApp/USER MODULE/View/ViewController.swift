//
//  ViewController.swift
//  UserApp
//
//  Created by Shubham Joshi on 10/10/21.
//

import UIKit
import Combine


class ViewController: UIViewController {
    var viewModel = UserViewModel()
    private var subscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getData()
        subscriber = viewModel.userSubject.sink { completion in
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
            case .finished: break
            }
        } receiveValue: { users in
            print(users.data)
        }
    }
}
