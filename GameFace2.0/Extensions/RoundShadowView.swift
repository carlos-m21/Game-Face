//Created for GameFace  (18.03.2021 )

import UIKit


class RoundShadowView: UIView {
  
    
    //View vars
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 8.0
    private var fillColor: UIColor = .black // the color applied to the shadowLayer, rather than the view's backgroundColor
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

       
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layoutSubviews()
    }
    
  
    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
          
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = UIColor.clear.cgColor
                //

            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 3.0)
            shadowLayer.shadowOpacity = 0.4
            shadowLayer.shadowRadius = 20

            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}
