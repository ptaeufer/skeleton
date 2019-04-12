import UIKit

extension UINavigationBar {
    func setLogo(image: UIImage) {
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 17))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 140, height: 17))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        logoContainer.addSubview(imageView)
        logoContainer.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        self.addSubview(logoContainer)
    }
}
