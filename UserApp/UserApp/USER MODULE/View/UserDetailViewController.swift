//
//  UserDetailViewController.swift
//  UserApp
//
//  Created by Shubham Joshi on 10/10/21.
//

import UIKit
import Combine

class UserDetailViewController: UIViewController {
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
   
    var userID: String?
    private var viewModel = UserViewModel()
    private var subscriber: AnyCancellable?
    private var userDetail: UserDetail? {
        didSet {
            setDetails()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userID = self.userID else { return }
        activityIndicator.startAnimating()
        viewModel.getUser(by: userID)
        setSubscriber()
    }
    
    private func setSubscriber() {
        subscriber = viewModel.userDetailSubject.sink {[weak self] completion in
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
                self?.navigationController?.popViewController(animated: true)
            case .finished: break
            }
            self?.activityIndicator.stopAnimating()
        } receiveValue: {[weak self] detail in
            self?.userDetail = detail
            self?.activityIndicator.stopAnimating()
        }
    }
    
    private func setDetails() {
        title = userDetail?.firstName.capitalized
    }
}
