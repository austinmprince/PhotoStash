//
//  SlideInPresentationManager.swift
//  PhotoStash
//
//  Created by Glizela Taino on 2/20/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit

enum PresentationDirection {
    case top
    case bottom
}

class SlideInPresentationManager: NSObject {
    
    var direction = PresentationDirection.top

}

extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(presentedViewController: presented,
                                                                   presenting: presenting,
                                                                   direction: direction)
        return presentationController
    }
    
}
