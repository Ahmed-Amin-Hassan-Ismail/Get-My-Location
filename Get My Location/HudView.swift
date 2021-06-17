//
//  HudView.swift
//  Get My Location
//
//  Created by Amin  on 6/17/21.
//  Copyright © 2021 AhmedAmin. All rights reserved.
//

import UIKit

class HudView: UIView {
    
    var text = " "
    
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.showAnimation(animated: animated)
        return hudView
    }
    
    
    override func draw(_ rect: CGRect) {
        
        // HUD Drawing
        let boxWidth: CGFloat = 96.0
        let boxHeight: CGFloat = 96.0
        let boxRect = CGRect(x: round(bounds.size.width - boxWidth) / 2,
                             y: round(bounds.size.height - boxHeight) / 2,
                             width: boxWidth, height: boxHeight)
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10.0)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        // Draw the image
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: (center.x - round(image.size.width / 2)),
                y: (center.y - round(image.size.height / 2)) - (boxHeight / 8) )
            image.draw(at: imagePoint)
        }
        
        // Draw the text
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textPoint = CGPoint(
            x: (center.x - round(textSize.width / 2)),
            y: (center.y - round(textSize.height / 2)) + (boxHeight / 4))
        
        text.draw(at: textPoint, withAttributes: attributes)
        
        
        
    }
    
    // Hide HUD View
    func hideHUD() {
        superview?.isUserInteractionEnabled = true
        removeFromSuperview()
    }
    
    
    private func showAnimation(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
    
    
}
