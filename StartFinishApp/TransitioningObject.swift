//
//  TransitioningObject.swift
//  StartFinishApp
//
//  Created by Andrey Tkachov on 06.02.17.
//  Copyright © 2017 Kostiantyn Tkachov. All rights reserved.
//

import UIKit

class TransitioningObject: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Get the "from" and "to" views
        let fromView : UIView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView : UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        transitionContext.containerView.addSubview(fromView)
        transitionContext.containerView.addSubview(toView)
        
        //The "to" view with start "off screen" and slide left pushing the "from" view "off screen"
        toView.frame = CGRect(x: toView.frame.width,y: 0, width: toView.frame.width,height:  toView.frame.height)
        let fromNewFrame = CGRect(x: -1 * fromView.frame.width, y: 0,width: fromView.frame.width, height: fromView.frame.height)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            toView.frame = CGRect(x: 0, y:0, width: 320, height: 560)
            fromView.frame = fromNewFrame
        }) { (Bool) -> Void in
            // update internal view - must always be called
            transitionContext.completeTransition(true)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
}
