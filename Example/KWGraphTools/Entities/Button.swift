//
//  Button.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 01/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SpriteKit

enum ButtonEvent {
    case began
    case moved
    case ended
    case cancelled
}

typealias ButtonAction = (Button) -> Void

final class Button: SKSpriteNode {
    var actions: [ButtonEvent: ButtonAction] = [:]
    
    func execute(buttonEvent event: ButtonEvent) {
        guard let action = actions[event] else { return }
        action(self)
    }
}
