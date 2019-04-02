//
//  ViewController.swift
//  SwiftHoledView
//
//  Created by Mazy on 2019/4/1.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var holedView: SwiftHoledView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        holedView = SwiftHoledView(frame: view.bounds)
        view.addSubview(holedView)
        holedView.holeViewDelegate = self
        holedView.addHoleCircleCenteredOnPosition(CGPoint(x: 25, y: 40), diameter: 40)
        holedView.addHoleRectOnRect(CGRect(x: 10, y: 150, width: 300, height: 30))
//        holedView.addRoundedRectHole(onRect: <#T##CGRect#>, cornerRadius: <#T##CGFloat#>, text: <#T##String#>, onPostion: <#T##HolePosition#>, margin: <#T##CGFloat#>)
        
    }


}

extension ViewController: HoledViewDelegate {
    func holedView(_ holedView: SwiftHoledView, didSelectHoleAtIndex index: Int) {
        print(index)
    }
    
    func holedView(_ holedView: SwiftHoledView, willAddLabel laber: UILabel, atIndex index: Int) {
        
    }
}

