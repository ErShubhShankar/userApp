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
    
    
    @IBOutlet weak var viewAddBG: UIView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var collectionUsers: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        viewModel.getUsers(page: 1, limit: limit)
        setupCollectionView()
        setSubscriber()
        let shadowColor = #colorLiteral(red: 0.9647058824, green: 0.7607843137, blue: 0.2588235294, alpha: 1)
        viewAddBG.dropShadow(color: shadowColor, opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 23)
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
