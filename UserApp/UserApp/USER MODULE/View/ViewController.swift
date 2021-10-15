//
//  ViewController.swift
//  UserApp
//
//  Created by Shubham Joshi on 10/10/21.
//

import UIKit
import Combine

enum Section {
    case user
}

class ViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, User>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, User>
    
    private var viewModel = UserViewModel()
    private var subscriber: AnyCancellable?
    private var userDataSource: DataSource!
    private var arrayUsers: [User] = []
    private var totalPage: Int = 10
    private var currentPage: Int = 1
    private var limit: Int {
        return 10
    }
    
    @IBOutlet weak private var viewAddUser: UIView!
    @IBOutlet weak private var buttonAdd: UIButton!
    @IBOutlet weak private var viewAddBG: UIView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textFieldFName: UITextField!
    @IBOutlet weak var textFieldLName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak private var collectionUsers: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        viewModel.getUsers(page: 1, limit: limit)
        setupCollectionView()
        setSubscriber()
        setupUI()
    }
    
    private func setupUI() {
        let shadowThemeColor = #colorLiteral(red: 0.9647058824, green: 0.7607843137, blue: 0.2588235294, alpha: 1)
        let black10color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
        viewAddBG.dropShadow(color: shadowThemeColor, opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 23)
        buttonAdd.dropShadow(color: black10color, opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 5)
        viewAddUser.dropShadow(color: .black, opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 100)
        textFieldFName.textContentType = .givenName
        textFieldLName.textContentType = .middleName
        textFieldEmail.textContentType = .emailAddress
        textFieldFName.delegate = self
        textFieldLName.delegate = self
        textFieldEmail.delegate = self
    }
    
    private func setupCollectionView() {
        UserCollectionCell.register(for: collectionUsers)
        collectionUsers.collectionViewLayout = creatLayout()
        createDataSource()
    }
    
    private func setSubscriber() {
        subscriber = viewModel.userSubject.sink {[weak self] completion in
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
            case .finished: break
            }
            self?.activityIndicator.stopAnimating()
        } receiveValue: {[weak self] users in
            self?.arrayUsers.append(contentsOf: users.data ?? [])
            self?.applySnapShot()
            self?.activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func actionOnButtonAdd(_ sender: UIButton) {
        sender.bounceAnimation()
        sender.isUserInteractionEnabled = false
        viewAddUser.transform = CGAffineTransform(scaleX: 0, y: 0)
        if viewAddUser.isHidden {
            UIView.animate(withDuration: 0.4, animations: {
                self.viewAddUser.alpha = 1.0
                self.viewAddUser.transform =  .identity
                self.viewAddUser.isHidden = false
            }, completion: {_ in
                sender.isUserInteractionEnabled = true
            })
        }
    }
    
    @IBAction func actionOnButtonAddUser(_ sender: UIButton) {
        view.endEditing(true)
        guard let fName = textFieldFName.text, !fName.isEmpty else {
            textFieldFName.superview?.shake()
            return
        }
        guard let lName = textFieldLName.text, !lName.isEmpty else {
            textFieldLName.superview?.shake()
            return
        }
        guard let email = textFieldEmail.text, !email.isEmpty else {
            textFieldEmail.superview?.shake()
            return
        }
        //TODO: ADD VALIDATION
        let  user = User(id: "1", firstName: fName, lastName: lName, email: email)
        viewModel.create(user: user)
    }
    
    @IBAction func actionOnButtonClose(_ sender: UIButton) {
        view.endEditing(true)
        UIView.animate(withDuration: 0.4, animations: {
            self.viewAddUser.alpha = 0
            self.viewAddUser.transform = CGAffineTransform(scaleX: 0, y: 0)
        }) { _ in
            self.viewAddUser.isHidden = true
        }
    }
}

//MARK: - Setup CollectionView
extension ViewController {
    func createDataSource() {
        userDataSource = .init(collectionView: collectionUsers, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell: UserCollectionCell = collectionView.dequeueCell(for: indexPath)
            cell.user = itemIdentifier
            return cell
        })
        applySnapShot()
    }
    
    func createSnapshot() -> Snapshot {
        var snaphot = Snapshot()
        snaphot.appendSections([.user])
        snaphot.appendItems(arrayUsers, toSection: .user)
        return snaphot
    }
    
    func creatLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        group.interItemSpacing = .fixed(20)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 40, leading: 0, bottom: 0, trailing: 0)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func applySnapShot() {
        userDataSource.apply(createSnapshot(), animatingDifferences: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == arrayUsers.count-1, currentPage < totalPage {
            currentPage += 1
            self.activityIndicator.startAnimating()
            viewModel.getUsers(page: currentPage, limit: limit)
        } 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let user = userDataSource.itemIdentifier(for: indexPath) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailViewController = storyboard.instantiateViewController(withIdentifier: "UserDetailViewController")  as? UserDetailViewController {
                detailViewController.userID = user.id
                detailViewController.title = user.firstName.capitalized
                navigationController?.pushViewController(detailViewController, animated: true)
            }
        }
    }
    
    //ANIMATION
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? UserCollectionCell {
            UIView.animate(withDuration: 0.3) {
                cell.viewBG.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? UserCollectionCell {
            UIView.animate(withDuration: 0.3) {
                cell.viewBG.transform = .identity
            }
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldFName:
            textFieldLName.becomeFirstResponder()
        case textFieldLName:
            textFieldEmail.becomeFirstResponder()
        default:
            view.endEditing(true)
        }
        return true
    }
}
