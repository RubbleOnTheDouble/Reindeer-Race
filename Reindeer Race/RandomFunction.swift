//
//  RandomFunction.swift
//  Reindeer Race
//
//  Created by Colleen Prescod on 2016-09-03.
//  Copyright © 2016 Colleen Prescod. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{

    public static func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min min : CGFloat, max : CGFloat) -> CGFloat{
        return CGFloat.random() * (max - min) + min
    }

}
