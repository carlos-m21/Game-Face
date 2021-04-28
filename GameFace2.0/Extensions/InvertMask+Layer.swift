//Created for GameFace  (17.03.2021 )

import UIKit



extension UIView {
    func mask(withRect rect: CGRect, cornerRadius: CGFloat = 16,  inverse: Bool = false) {
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height), cornerRadius: self.bounds.size.height/2)
        
        let circlePath = UIBezierPath(roundedRect: rect, cornerRadius: rect.height/2)
        path.append(circlePath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.5
        self.layer.addSublayer(fillLayer)
        
    }
}




