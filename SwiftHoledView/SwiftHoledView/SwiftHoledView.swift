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
    case topRightCorner
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
    var holeType: HoloType = .circle
}

class CircleHole: BaseHole {
    var centerPoint: CGPoint = .zero
    var diameter: CGFloat = 0
    // height scale factor（for oval hole）
    var hScale: CGFloat = 0
}


class RectHole: BaseHole {
    var holeRect: CGRect = .zero
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
    
    var dimingColor: UIColor = UIColor.black.withAlphaComponent(0.5) {
        didSet {
           self.setNeedsDisplay()
        }
    }
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
    
    @objc func tapGestureDetected(_ geture: UITapGestureRecognizer) {
        let touchLocation = geture.location(in: self)
        let index = self.holeViewIndexForAtPoint(touchLocation)
        holeViewDelegate?.holedView(self, didSelectHoleAtIndex: index)
    }
    
    override func draw(_ rect: CGRect) {
        removeCustomViews()
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        self.dimingColor.setFill()
        UIRectFill(rect)
        
        for hole in self.holes {
            UIColor.clear.setFill()
            switch hole.holeType {
            case .roundedRect:
                let rectHole = hole as! RoundedRectHole
                let holeRectIntersection = rectHole.holeRect.intersection(self.frame)
                let bezierPath = UIBezierPath(roundedRect: holeRectIntersection, cornerRadius: rectHole.cornerRadius)

                context.setFillColor(UIColor.clear.cgColor)
                context.addPath(bezierPath.cgPath)
                context.setBlendMode(.clear)
                context.fillPath()
            case .rect:
                let rectHole = hole as! RectHole
                let holeRectIntersection = rectHole.holeRect.intersection(self.frame)
                UIRectFill(holeRectIntersection)
            case .circle:
                let circleHole = hole as! CircleHole
                let rectInView = CGRect(x: CGFloat(floorf(Float(circleHole.centerPoint.x - circleHole.diameter / 2))),
                                        y: CGFloat(floorf(Float(circleHole.centerPoint.y - circleHole.diameter / 2))) + circleHole.diameter * (1 - circleHole.hScale) / 2,
                                        width: circleHole.diameter,
                                        height: circleHole.diameter * circleHole.hScale)
                context.setFillColor(UIColor.clear.cgColor)
                context.setBlendMode(.clear)
                context.fillEllipse(in: rectInView)
            default:
                break
            }
        }
        self.addCustomViews()
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
    
    public func addHoleRoundedRectOnRect(_ rect: CGRect, cornerRadius: CGFloat) -> Int {
        let rectHole = RoundedRectHole()
        rectHole.holeRect = rect
        rectHole.cornerRadius = cornerRadius
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
        _ = self.addHoleCircleCenteredOnPosition(centerPoint, diameter: diameter)
        _ = buildLabel(point: centerPoint, holeWidht: diameter, holeHeight: diameter, text: text, onPosition: onPosition, margin: margin)
    }
    
    public func addRectHole(onRect rect: CGRect, text: String, onPostion: HolePosition, margin: CGFloat) {
        _ = self.addHoleRectOnRect(rect)
        _ = buildLabel(point: CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2), holeWidht: rect.size.width, holeHeight: rect.size.height, text: text, onPosition: onPostion, margin: margin)
    }
    
    public func addRoundedRectHole(onRect rect: CGRect, cornerRadius: CGFloat, text: String, onPostion: HolePosition, margin: CGFloat) {
        _ = self.addHoleRoundedRectOnRect(rect, cornerRadius: cornerRadius)
        _ = buildLabel(point: CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2), holeWidht: rect.size.width, holeHeight: rect.size.height, text: text, onPosition: onPostion, margin: margin)
    }
    
    public func addRoundedRectHole(onRect rect: CGRect, cornerRadius: CGFloat, attributedText: NSAttributedString, onPostion: HolePosition, margin: CGFloat) {
        _ = self.addHoleRoundedRectOnRect(rect, cornerRadius: cornerRadius)
        _ = buildLabel(point: CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2), holeWidht: rect.size.width, holeHeight: rect.size.height, attrText: attributedText, onPosition: onPostion, margin: margin)
    }

    public func removeHoles() {
        removeCustomViews()
        self.holes.removeAll()
        self.setNeedsDisplay()
    }
}


// MARK: - private
extension SwiftHoledView {
    
    func buildLabel(point: CGPoint, holeWidht: CGFloat, holeHeight: CGFloat, attrText: NSAttributedString, onPosition: HolePosition, margin: CGFloat) -> UILabel {
        
        let text = attrText.string
        let centerPoint = point
        let holeWidthHalf = holeWidht / 2 + margin
        let holeHeightHalf = holeHeight / 2 + margin
        
        let attrs = attrText.attributes(at: 0, longestEffectiveRange: nil, in: NSRange(location: 0, length: text.count))
        let fontSize = text.size(withAttributes: attrs)
        
        var x: CGFloat = centerPoint.x
        var y: CGFloat = centerPoint.y
        switch onPosition {
        case .top:
            x = centerPoint.x - fontSize.width / 2
            y = (centerPoint.y - holeHeightHalf) - fontSize.height
        case .topRightCorner:
            x = centerPoint.x + holeWidthHalf
            y = (centerPoint.y - holeHeightHalf) - fontSize.height
        case .right:
            x = centerPoint.x + holeWidthHalf
            y = centerPoint.y - fontSize.height / 2
        case .bottomRightCorner:
            x = centerPoint.x + holeWidthHalf
            y = centerPoint.y + holeHeightHalf
        case .bottom:
            x = centerPoint.x - fontSize.width / 2
            y = centerPoint.y + holeHeightHalf
        case .bottomLeftCorner:
            x = (centerPoint.x - holeWidthHalf) - fontSize.width
            y = centerPoint.y + holeHeightHalf
        case .left:
            x = centerPoint.x - holeWidthHalf - fontSize.width
            y = centerPoint.y - fontSize.height / 2
        case .topLeftCorner:
            x = centerPoint.x - holeWidthHalf - fontSize.width
            y = centerPoint.y - holeHeightHalf - fontSize.height / 2
        }
        
        let frame = CGRect(x: x, y: y, width: fontSize.width, height: fontSize.height)
        
        let label = UILabel(frame: frame)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = attrText
        if self.holeViewDelegate != nil {
            let labels = self.holes.filter({ $0.isKind(of: CustomRectHole.self) })
            let index = labels.count - 1
            self.holeViewDelegate?.holedView(self, willAddLabel: label, atIndex: index)
        }
        _ = addCustomView(label, onRect: label.frame)
        return label
    }
    
    func buildLabel(point: CGPoint, holeWidht: CGFloat, holeHeight: CGFloat, text: String, onPosition: HolePosition, margin: CGFloat) -> UILabel {
        let attrString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: self.textFont])
        let label = self.buildLabel(point: point, holeWidht: holeWidht, holeHeight: holeHeight, attrText: attrString, onPosition: onPosition, margin: margin)
        return label
    }
    
    /*
     case circle
     case rect
     case roundedRect
     case customRect
     */
    func holeViewIndexForAtPoint(_ touchLocation: CGPoint) -> Int {
        var idxToReturn: Int = 0
        self.holes.enumerated().forEach { (index, hole) in
            switch hole.holeType {
            case .rect, .roundedRect, .customRect:
                let rectHole = hole as! RectHole
                if rectHole.holeRect.contains(touchLocation) {
                    idxToReturn = index
                }
            case .circle:
                let circleHole = hole as! CircleHole
                let rectInView = CGRect(x: CGFloat(floorf(Float(circleHole.centerPoint.x - circleHole.diameter / 2))), y: CGFloat(floorf(Float(circleHole.centerPoint.y - circleHole.diameter / 2))), width: circleHole.diameter, height: circleHole.diameter)
                if rectInView.contains(touchLocation) {
                    idxToReturn = index
                }
            }
        }
        return idxToReturn
    }
    
    func removeCustomViews() {
        self.holes.filter({ $0.isKind(of: CustomRectHole.self) }).map({ $0 as! CustomRectHole } ).forEach({ $0.customView?.removeFromSuperview() })
    }
    
    func addCustomViews() {
        self.holes.filter({ $0.isKind(of: CustomRectHole.self) }).map({ $0 as! CustomRectHole } ).forEach { (customHole) in
            guard let customView = customHole.customView else {
                return
            }
            customView.frame = customHole.holeRect
            self.addSubview(customView)
        }
    }
}
