//
//  CustomBar.swift
//  CustomBar
//
//  Created by Marco Falanga on 28/09/18.
//  Copyright © 2018 Marco Falanga. All rights reserved.
//

import UIKit

//extension UIView
extension UIView {
    //roundCorner makes rounded the corners (roundingCorner: UIRectCorner)
    //NOTE: use it in layoutSubviews, if you use it before, it might cause strange behaviours
    func roundCorner(roundingCorners: UIRectCorner, cornerRadius: CGSize) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerRadius)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

//*** CUSTOM VIEW ***

@IBDesignable
class CustomBar: UIView {

    @IBOutlet var contentView: UIView!
    
    //percentage (0.0 - 1.0 values)
    @IBInspectable
    var percentage: CGFloat = 0.5 {
        didSet {
            setupBar()
        }
    }
    
    //color is the background color with alpha 0.2 and the bar color with alpha 1.0
    @IBInspectable
    var color: UIColor = .blue {
        didSet {
            setupBar()
        }
    }
    
    //there are 4 booleans to set the roundCorners on Storyboard
    @IBInspectable var isTopRight: Bool = false {
        didSet {
            if isTopRight {
                roundCorners.insert(.topRight)
            }
            else {
                roundCorners.remove(.topRight)
            }
        }
    }
    @IBInspectable var isTopLeft: Bool = false {
        didSet {
            if isTopLeft {
                roundCorners.insert(.topLeft)
            }
            else {
                roundCorners.remove(.topLeft)
            }
        }
    }
    @IBInspectable var isBottomRight: Bool = false {
        didSet {
            if isBottomRight {
                roundCorners.insert(.bottomRight)
            }
            else {
                roundCorners.remove(.bottomRight)
            }
        }
    }
    @IBInspectable var isBottomLeft: Bool = false {
        didSet {
            if isBottomLeft {
                roundCorners.insert(.bottomLeft)
            }
            else {
                roundCorners.remove(.bottomLeft)
            }
        }
    }
    
    //corner radius
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    
    //roundCorners, if you set it it calls UIView.roundCorner (see layoutSubviews)
    var roundCorners: UIRectCorner = [] {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    //animation duration
    var duration: Double = 2
    //bar
    var barView: UIView = UIView()
    //shape
    var shape = CAShapeLayer()
    //label
    var countingLabel = UILabel()
    
    //label's font
    var font: UIFont = .systemFont(ofSize: 20) {
        didSet {
            setupBar()
        }
    }
    
    //label text color
    @IBInspectable var fontColor: UIColor = .white {
        didSet {
            setupBar()
        }
    }
    
    //value to start the label count
    var startValue = 0.0
    //displayLink
    var displayLink = CADisplayLink()
    
    //in each init you call commonInit to load the nib file and to set some properties
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
  
        let bundle = Bundle(for: CustomBar.self)
        bundle.loadNibNamed("CustomBar", owner: self, options: nil)

//        Bundle.main.loadNibNamed("CustomBar", owner: self, options: nil)
        //NOTE: if you set the bundle like I did, you can use it on Storyboard
        //if you use the commented line instead, there is an error about the designable
        
        
        //setup contentView
        addSubview(contentView)
        self.backgroundColor = .clear
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.clipsToBounds = true
        
        //setup displayLink for the counting label
        displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        displayLink.add(to: .main, forMode: .default)
        displayLink.preferredFramesPerSecond = 20
        
        //setupBar (shape and CoreAnimation)
        setupBar()
    }
    
    private func setupBar() {
        
        //setup background color
        contentView.backgroundColor = color.withAlphaComponent(0.2)
        
        //setup bar AUTOLAYOUT
        barView.removeFromSuperview()
        shape.removeFromSuperlayer()
        barView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(barView)
        
        barView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        barView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        barView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        barView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: percentage).isActive = true
        
        
        //setup label AUTOLAYOUT
        countingLabel.removeFromSuperview()
        countingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(countingLabel)
        countingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        countingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        countingLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        countingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        countingLabel.textAlignment = .center
        countingLabel.font = font
        countingLabel.textColor = fontColor
        countingLabel.text = "0.00 %"
        countingLabel.adjustsFontSizeToFitWidth = true
        startValue = 0.0
        
        //you need it to update barView.frame
        self.layoutIfNeeded()

        //setup SHAPE and CoreAnimation
        shape.path = UIBezierPath(rect: barView.frame).cgPath
        
        shape.fillColor = color.cgColor
        barView.layer.addSublayer(shape)

        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = CATransform3DMakeScale(0, 1, 1)
        animation.toValue = CATransform3DIdentity
        animation.duration = duration
        shape.add(animation, forKey: "entry")
        
        //because it is paused when it reaches the values, check if it is paused and set it false
        if displayLink.isPaused {
            displayLink.isPaused = false
        }
    }
    
    //function called by displayLink, it makes the label count
    @objc func handleUpdate() {
        countingLabel.text = "\(Double(startValue * 100).rounded(toPlaces: 2)) %"
        //this makes the counting animation takes as long as the bar's animation
        startValue += Double(percentage) / (Double(20) * Double(duration))
        
        print(startValue, duration, percentage)
        
        if startValue > Double(percentage) {
            startValue = Double(percentage)
            displayLink.isPaused = true
        }
    }
    
    override func layoutSubviews() {
        contentView.roundCorner(roundingCorners: roundCorners, cornerRadius: CGSize(width: cornerRadius, height: cornerRadius))
    }

}
