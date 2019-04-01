//
//  SwiftHoledView.swift
//  SwiftHoledView
//
//  Created by Mazy on 2019/4/1.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

enum HoloType {
    case circle
    case rect
    case roundedRect
    case customRect
}

enum HolePosition {
    case top
    case rightCorner
    case right
    case bottomRightCorner
    case bottom
    case bottomLeftCorner
    case left
    case topLeftCorner
}

protocol HoledViewDelegate {
    func holedView(_ holedView: SwiftHoledView, didSelectHoleAtIndex index: Int)
    func holedView(_ holedView: SwiftHoledView, willAddLabel laber: UILabel, atIndex index: Int)
}


class BaseHole: NSObject {
    var holeType: HoloType?
}

class CircleHole: BaseHole {
    var centerPoint: CGPoint = .zero
    var diameter: CGFloat = 0
    // height scale factor（for oval hole）
    var hScale: CGFloat = 0
}


class RectHole: BaseHole {
    var holeRect: CGRect?
}

class RoundedRectHole: RectHole {
    var cornerRadius: CGFloat = 0
}


class CustomRectHole: RectHole {
    var customView: UIView?
}



class SwiftHoledView: UIView {

    // Array of JMHole
    private lazy var holes: [BaseHole] = []
    lazy var dimingColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    var holeViewDelegate: HoledViewDelegate?
    lazy var textFont: UIFont = UIFont.systemFont(ofSize: 14)

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDetected))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapGestureDetected() {
        
    }
    
    override func draw(_ rect: CGRect) {
        
    }
}


// MARK: - public
extension SwiftHoledView {
    
    public func addHoleCircleCenteredOnPosition(_ centerPoint: CGPoint, diameter: CGFloat, hScale: CGFloat = 1) -> Int  {
        let circleHole = CircleHole()
        circleHole.centerPoint = centerPoint
        circleHole.diameter = diameter
        circleHole.hScale = hScale
        circleHole.holeType = .circle
        self.holes.append(circleHole)
        self.setNeedsDisplay()
        return self.holes.firstIndex(of: circleHole) ?? 0
    }

    public func addHoleRectOnRect(_ rect: CGRect) -> Int {
        let rectHole = RectHole()
        rectHole.holeRect = rect
        rectHole.holeType = .rect
        self.holes.append(rectHole)
        self.setNeedsDisplay()
        return self.holes.firstIndex(of: rectHole) ?? 0
    }
    
    public func addHoleRoundedRectOnRect(_ rect: CGRect) -> Int {
        let rectHole = RoundedRectHole()
        rectHole.holeRect = rect
        rectHole.holeType = .roundedRect
        self.holes.append(rectHole)
        self.setNeedsDisplay()
        return self.holes.firstIndex(of: rectHole) ?? 0
    }
    
    public func addCustomView(_ view: UIView, onRect: CGRect) -> Int {
        let customHole = CustomRectHole()
        customHole.holeRect = onRect
        customHole.customView = view
        customHole.holeType = .customRect
        self.holes.append(customHole)
        self.setNeedsDisplay()
        return self.holes.firstIndex(of: customHole) ?? 0
    }
    
 
    public func addCircleHole(centeredOnPosition centerPoint: CGPoint, diameter: CGFloat, text: String, onPosition: HolePosition, margin: CGFloat) {
        self.addHoleCircleCenteredOnPosition(centerPoint, diameter: diameter)
        //
    }
    
    public func addRectHole(onRect rect: CGRect, text: String, onPostion: HolePosition, margin: CGFloat) {
        self.addHoleRectOnRect(rect)
        //
    }
    
    public func addRoundedRectHole(onRect rect: CGRect, text: String, onPostion: HolePosition, margin: CGFloat) {
        
    }
    
    public func addRoundedRectHole(onRect rect: CGRect, attributedText: NSAttributedString, onPostion: HolePosition, margin: CGFloat) {
        
    }

    public func removeHoles() {
        
    }
}
