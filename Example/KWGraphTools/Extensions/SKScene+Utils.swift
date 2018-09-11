//
//  SKScene+Utils.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 28/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SpriteKit

extension SKScene {
    static var sceneName: String {
        return String(describing: self)
    }
}
