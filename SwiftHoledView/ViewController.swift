//
//  ViewController.swift
//  SwiftHoledView
//
//  Created by Mazy on 2019/4/1.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var segmentView: UISegmentedControl!
    @IBOutlet weak var switchView: UISwitch!
    @IBOutlet weak var textView: UITextView!
    
    var holedView: SwiftHoledView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        holedView = SwiftHoledView(frame: view.bounds)
        view.addSubview(holedView)
        holedView.holeViewDelegate = self
        
        redView.layer.cornerRadius = 50
        redView.clipsToBounds = true
        
        holedView.addHoleRect(redView.frame, cornerRadius: 50)
        
        holedView.addHoleRect(CGRect(x: 20, y: 200, width: 50, height: 50), cornerRadius: 0)
        
        holedView.addHoleRect(segmentView.frame)
        
        holedView.addRectHole(onRect: textView.frame, cornerRadius: 2, text: "hahahahah", onPostion: .top, margin: 0)
        
        holedView.addCustomView(switchView, onRect: textView.frame)
    }


}

extension ViewController: HoledViewDelegate {
    func holedView(_ holedView: SwiftHoledView, didSelectHoleAtIndex index: Int) {
        print(index)
        if index == 3 {
            holedView.removeFromSuperview()
        }
    }
    
    func holedView(_ holedView: SwiftHoledView, willAddLabel laber: UILabel, atIndex index: Int) {
        
    }
}

