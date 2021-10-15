//
//  Common Extension.swift
//  CNSApp
//
//  Created by Shubham Joshi on 10/10/21.
//

import Foundation
import UIKit
import Kingfisher

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "Invalid response")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Unknown error")
        }
    }
}

extension CustomStringConvertible where Self: Codable {
    var description: String {
        var description = "\n \(type(of: self)) \n"
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                description += "\(propertyName): \(child.value)\n"
            }
        }
        return description
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        } get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        set {
            layer.borderColor = newValue.cgColor
        } get {
            return UIColor(cgColor: layer.borderColor ?? CGColor.init(red: 0, green: 0, blue: 0, alpha: 0))
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        } get {
            return layer.borderWidth
        }
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
      }
    
    func bounceAnimation(duration: CGFloat = 0.5,
                         animationValues: [CGFloat] = [1.0, 1.4, 0.9, 1.15, 0.95, 1.02, 1.0],
                         completion: (() -> Swift.Void)? = nil) {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = animationValues
        bounceAnimation.duration = TimeInterval(duration)
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        layer.add(bounceAnimation, forKey: nil)
        CATransaction.commit()
    }
    
    func shake(for duration: TimeInterval = 0.5, withTranslation translation: CGFloat = 10) {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.3) {
            self.transform = CGAffineTransform(translationX: translation, y: 0)
        }
        propertyAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: 0.2)
        
        propertyAnimator.startAnimation()
    }
}

extension UICollectionViewCell {
  static var reuseIdentifier: String {
    return String(describing: self)
  }
  static func register(for collectionView: UICollectionView) {
    let bundle = Bundle(for: self)
    let cellName = String(describing: self)
    let cellIdentifier = reuseIdentifier
    let cellNib = UINib(nibName: cellName, bundle: bundle)
    collectionView.register(cellNib, forCellWithReuseIdentifier: cellIdentifier)
  }
    
    static func registerClass(for collectionView: UICollectionView) {
        collectionView.register(self, forCellWithReuseIdentifier: reuseIdentifier)
    }

  static func register(for collectionViews: [UICollectionView]) {
    collectionViews.forEach({
      register(for: $0)
    })
  }
}

extension UICollectionView {
    func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
      guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
        fatalError("Could not deque cell -> \(T.reuseIdentifier)")
      }
      return cell
    }
}


extension UIImageView {
    func downloadImage(imageInfo: ImageInfo, completion: ((Bool) -> Void)? = nil) {
        var options: KingfisherOptionsInfo? = [.memoryCacheExpiration(.days(5)), .diskCacheExpiration(.days(5))]
        if !imageInfo.storeInCache {
            options = [.memoryCacheExpiration(.expired), .diskCacheExpiration(.expired)]
        }
        let url = URL(string: imageInfo.fileUrl)
        self.kf.setImage(with: url, options: options) { (_) in
            self.contentMode = imageInfo.contentMode
        }
    }
}
