//
//  DemoViewController.swift
//  SwiftHoledView
//
//  Created by Mazy on 2019/4/2.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

class DemoViewController: UITableViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var firstCell: UITableViewCell!
    
    var holedView: SwiftHoledView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []
        
        holedView = SwiftHoledView(frame: view.bounds)
        
        holedView!.holeViewDelegate = self
        
//        holedView?.addHoleRect(iconImageView.frame, cornerRadius: iconImageView.frame.height / 2)
        
        holedView?.addRectHole(onRect: iconImageView.frame, cornerRadius: iconImageView.frame.height / 2, text: "ddddddddddd", onPostion: .right, margin: 10)
        
        let followBtnFrameInTableView = tableView.convert(followButton.frame, from: followButton.superview?.superview)
        holedView?.addHoleRect(followBtnFrameInTableView)
        holedView?.addRectHole(onRect: followBtnFrameInTableView, cornerRadius: 0, text: "follow action", onPostion: .bottom, margin: 10)
        
        
        holedView?.addHoleRect(firstCell.frame)
        holedView?.addRectHole(onRect: firstCell.frame, cornerRadius: 0, text: "cell description", onPostion: .top, margin: 10)
        
        let customView = viewForDemo()
        holedView?.addCustomView(customView, onRect: customView.frame)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.addSubview(holedView!)
    }
    
    func viewForDemo() -> UIView {
        
        let label = UILabel(frame: CGRect(x: (view.bounds.width  - 200) / 2, y: 400, width: 200, height: 50))
        label.backgroundColor = .clear
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 1.0
        label.layer.cornerRadius = 10
        label.textColor = UIColor.white
        label.text = "This control can be use to Highlight informations."
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }
}


extension DemoViewController: HoledViewDelegate {
    
    func holedView(_ holedView: SwiftHoledView, didSelectHoleAtIndex index: Int) {
        print(index)
        if index == 3 {
            holedView.removeFromSuperview()
        }
    }
    
    func holedView(_ holedView: SwiftHoledView, willAddLabel laber: UILabel, atIndex index: Int) {
        print("willAddLabel-----------")
    }
}

