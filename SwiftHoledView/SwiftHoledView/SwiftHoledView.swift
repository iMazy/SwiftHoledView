//
//  SwiftHoledView.swift
//  SwiftHoledView
//
//  Created by Mazy on 2019/4/1.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

enum HoloType {
    case rect // 矩形
    case roundedRect // 带圆角的矩形,当圆角等于宽/高的一半时,是圆形 round half == circle
    case customRect // 自定义形状
}

enum HolePosition {
    case top // 顶部
    case topRightCorner // s右上角
    case right // 右边
    case bottomRightCorner // 右下角
    case bottom // 底部
    case bottomLeftCorner // 左下角
    case left // 左边
    case topLeftCorner // 左上角
}

protocol HoledViewDelegate {
    // 点击某个 hole 时
    func holedView(_ holedView: SwiftHoledView, didSelectHoleAtIndex index: Int)
    // 添加 label 时
    func holedView(_ holedView: SwiftHoledView, willAddLabel laber: UILabel, atIndex index: Int)
}


/// base hole
class BaseHole: NSObject {
    var holeType: HoloType = .rect
}
/// 矩形 hole
class RectHole: BaseHole {
    var holeRect: CGRect = .zero
}

/// 带圆角的矩形, 可以是圆形
class RoundedRectHole: RectHole {
    var cornerRadius: CGFloat = 0
}

/// 自定义d形状
class CustomRectHole: RectHole {
    var customView: UIView?
}


///  holed view
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
        if index < 999 {        
            holeViewDelegate?.holedView(self, didSelectHoleAtIndex: index)
        }
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
            default:
                addCustomViews()
            }
        }
    }
}


// MARK: - public
extension SwiftHoledView {
    
    /// 添加矩形 hole
    ///
    /// - Parameters:
    ///   - rect: 大小
    ///   - cornerRadius: cornerRadius > 0 带圆角的矩形
    public func addHoleRect(_ rect: CGRect, cornerRadius: CGFloat = 0) {
        if cornerRadius == 0 {
            let rectHole = RectHole()
            rectHole.holeRect = rect
            rectHole.holeType = .rect
            self.holes.append(rectHole)
        } else {
            let rectHole = RoundedRectHole()
            rectHole.holeRect = rect
            rectHole.cornerRadius = cornerRadius
            rectHole.holeType = .roundedRect
            self.holes.append(rectHole)
        }
        self.setNeedsDisplay()
    }
    
    // 自定义形状
    public func addCustomView(_ view: UIView, onRect: CGRect) {
        let customHole = CustomRectHole()
        customHole.holeRect = onRect
        customHole.customView = view
        customHole.holeType = .customRect
        self.holes.append(customHole)
        self.setNeedsDisplay()
    }
    
    public func addRectHole(onRect rect: CGRect, cornerRadius: CGFloat, text: String, attributedText: NSAttributedString? = nil, onPostion: HolePosition, margin: CGFloat = 0) {
        addHoleRect(rect, cornerRadius: cornerRadius)
        buildLabel(holeRect: rect,
                   text: text,
                   attrText: attributedText,
                   onPosition: onPostion,
                   margin: margin)
    }

    public func removeHoles() {
        removeCustomViews()
        self.holes.removeAll()
        self.setNeedsDisplay()
    }
}


// MARK: - private
extension SwiftHoledView {
    
    func buildLabel(holeRect rect: CGRect, text: String = "", attrText: NSAttributedString? = nil, onPosition: HolePosition, margin: CGFloat) {
        
        let attrString: NSAttributedString
        if let _attrText = attrText {
            attrString = _attrText
        } else {
            attrString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: textFont])
        }
        let centerPoint = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2)
        let holeWidthHalf = rect.size.width / 2 + margin
        let holeHeightHalf = rect.size.height / 2 + margin
        
        let fontSize = attrString.size()
        
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
        label.attributedText = attrString
        if self.holeViewDelegate != nil {
            let labels = self.holes.filter({ $0.isKind(of: CustomRectHole.self) })
            let index = labels.count - 1
            self.holeViewDelegate?.holedView(self, willAddLabel: label, atIndex: index)
        }
        addCustomView(label, onRect: label.frame)
    }
    
    /*
     case rect
     case roundedRect
     case customRect
     */
    func holeViewIndexForAtPoint(_ touchLocation: CGPoint) -> Int {
        var idxToReturn: Int = 999
        self.holes.enumerated().forEach { (index, hole) in
            switch hole.holeType {
            case .rect, .roundedRect, .customRect:
                let rectHole = hole as! RectHole
                if rectHole.holeRect.contains(touchLocation) {
                    idxToReturn = index
                }
            }
        }
        return idxToReturn
    }
    
    private func removeCustomViews() {
        self.holes.filter({ $0.isKind(of: CustomRectHole.self) }).map({ $0 as! CustomRectHole } ).forEach({ $0.customView?.removeFromSuperview() })
    }
    
    private func addCustomViews() {
        self.holes.filter({ $0.isKind(of: CustomRectHole.self) }).map({ $0 as! CustomRectHole } ).forEach { (customHole) in
            guard let customView = customHole.customView else {
                return
            }
            customView.frame = customHole.holeRect
            self.addSubview(customView)
        }
    }
}
