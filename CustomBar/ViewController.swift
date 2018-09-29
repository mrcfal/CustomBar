//
//  ViewController.swift
//  CustomBar
//
//  Created by Marco Falanga on 28/09/18.
//  Copyright © 2018 Marco Falanga. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var customBar: CustomBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TAP THE SCREEN TO UPDATE THE BAR WITH RANDOM VALUES
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    @objc func tapped() {
        //random percentage
        let value = CGFloat.random(in: 0...1)
        customBar.percentage = value
        
        //random colors
        let colors = [UIColor.orange, .blue, .purple, .black, .brown, .red]
        
        let valueInt = Int.random(in: 0...5)
        customBar.color = colors[valueInt]
        
        //set corner radius (but you can see it if roundCorners array is not empty
        customBar.cornerRadius = 10
        
        //0 or 1 to set each corner to be rounded or not randomly
        let r1 = Int.random(in: 0...1)
        let r2 = Int.random(in: 0...1)
        let r3 = Int.random(in: 0...1)
        let r4 = Int.random(in: 0...1)
        
        customBar.isTopLeft = r1 == 0 ? true : false
        customBar.isTopRight = r2 == 0 ? true : false
        customBar.isBottomLeft = r3 == 0 ? true : false
        customBar.isBottomRight = r4 == 0 ? true : false
    }


}

