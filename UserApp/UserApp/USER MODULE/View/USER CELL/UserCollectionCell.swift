//
//  UserCollectionCell.swift
//  UserApp
//
//  Created by Shubham Joshi on 10/10/21.
//

import UIKit


class UserCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelUserDescription: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        let shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
        viewBG.dropShadow(color: shadowColor, opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 4)
    }
    var user: User? {
        didSet {
            setDetail()
        }
    }
    
    private func setDetail() {
        guard let item = user else { return }
        let name = item.title+". " + item.firstName+" "+item.lastName
        labelUserName.text = name.capitalized
        labelUserDescription.text = item.id
        if let imageURL = item.picture, !imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let imageInfo = ImageInfo(fileUrl: imageURL)
            imageUser.downloadImage(imageInfo: imageInfo, completion: nil)
        }
    }
}
