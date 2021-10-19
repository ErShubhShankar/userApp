//
//  UserDetailViewController.swift
//  UserApp
//
//  Created by Shubham Joshi on 10/10/21.
//

import UIKit
import Combine

class UserDetailViewController: UIViewController {
  
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak private var viewPrimaryDetail: UIView!
    @IBOutlet weak private var viewOtherDetails: UIView!
    @IBOutlet weak private var buttonBirthday: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var textEmail: UITextView!
    @IBOutlet weak private var textGender: UITextField!
    @IBOutlet weak private var textName: UITextView!
    @IBOutlet weak private var imageUser: UIImageView!
    
    var userID: String?
    private var viewModel = UserViewModel()
    private var subscriber: AnyCancellable?
    private var userDeleteSubscriber: AnyCancellable?
    private var userDetail: UserDetail? {
        didSet {
            setDetails()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        guard let userID = self.userID else { return }
        activityIndicator.startAnimating()
        viewModel.getUser(by: userID)
        setSubscriber()
        datePicker.backgroundColor = .clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageUser.cornerRadius = imageUser.frame.height/2
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
        
        userDeleteSubscriber = viewModel.deleteResponse.sink {[weak self] completion in
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
                self?.navigationController?.popViewController(animated: true)
            case .finished: break
            }
            self?.activityIndicator.stopAnimating()
        } receiveValue: {[weak self] detail in
            let viewController = self?.navigationController?.viewControllers.filter({$0 is ViewController}).first as? ViewController
            viewController?.getData()
            self?.navigationController?.popViewController(animated: true)
            self?.activityIndicator.stopAnimating()
        }
        
    }
    
    @IBAction func actionOnButtonBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionOnDateChange(_ sender: Any) {
        userDetail?.dateOfBirth = datePicker.date.toString(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    }
    
    @IBAction func actionOnButtonBirthday(_ sender: Any) {
        
    }
    
    @IBAction func actionOnbuttonDelete(_ sender: Any) {
        guard let id = userDetail?.id else { return }
        viewModel.deleteUser(id: id)
    }
    
    private func setDetails() {
        guard let userDetail = self.userDetail else { return }
        var nameTitle = userDetail.title.capitalized
        nameTitle = nameTitle.isEmpty ? "" : nameTitle+". "
        textName.text = nameTitle + userDetail.firstName.capitalized+" "+(userDetail.lastName?.capitalized ?? "")
        textGender.text = userDetail.gender?.uppercased() ?? ""
        textEmail.text = userDetail.email?.uppercased() ?? ""
        if let imageURL = userDetail.picture, !imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let imageInfo = ImageInfo(fileUrl: imageURL)
            imageUser.downloadImage(imageInfo: imageInfo, completion: nil)
        }
        if let heightConstraint = textName.constraints.filter({$0.firstAttribute == .height}).first {
            heightConstraint.constant = textName.contentSize.height
        }
        
        let shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
        //viewPrimaryDetail.dropShadow(color: shadowColor, opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 4)
        viewOtherDetails.dropShadow(color: shadowColor, opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 10)
        if let birthDate = userDetail.dateOfBirth?.toDate() {
            datePicker.date = birthDate
        } else {
            datePicker.isHidden = true
        }
    }
}

extension String {
    func toDate(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let dateValue = formatter.date(from: self) {
            return dateValue
        }
        return nil
    }
}

extension Date {
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
