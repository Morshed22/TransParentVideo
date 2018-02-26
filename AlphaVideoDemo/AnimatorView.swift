//
//  AnimatorView.swift
//  AlphaVideoDemo
//
//  Created by Morshed Alam on 4/11/17.
//  Copyright © 2017 Morshed Alam. All rights reserved.
//

import UIKit

enum Direction { case In, Out }

protocol Animate { }

extension Animate where Self: UIViewController {
    
    func AnimateWithView(direction: Direction, speed: Double = 0.0) {
        
        switch direction {
        case .In:
            
            let animatorView = AVAnimatorView.aVAnimatorView(withFrame: view.frame)
            // Create and add a dim view
           //let animatorView = UIView(frame: view.frame)
            animatorView?.backgroundColor = UIColor.blue
           // dimView.alpha = 0.0
            view.addSubview(animatorView!)
            
            // Deal with Auto Layout
            animatorView?.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[dimView]|", options: [], metrics: nil, views: ["dimView": animatorView!]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimView]|", options: [], metrics: nil, views: ["dimView": animatorView!]))
            
            // Animate alpha (the actual "dimming" effect)
            UIView.animate(withDuration: speed) { () -> Void in
                //animatorView?.alpha = alpha
            }
            
        case .Out:
            UIView.animate(withDuration: speed, animations: { () -> Void in
                //self.view.subviews.last?.alpha = alpha
            }, completion: { (complete) -> Void in
                self.view.subviews.last?.removeFromSuperview()
            })
        }
}
}
