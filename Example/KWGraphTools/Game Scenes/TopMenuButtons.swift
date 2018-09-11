//
//  TopMenuButtons.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 01/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SpriteKit

private let ATLAS_NAME = "UI"

enum TopMenuButtonsName: String, NodeName {
    case TargetButton
    case WallButton
    case SpawnButton
    case Selector
    case StartStopButton
    case FastForwardButton
}

enum TopMenuButtonTextures: String {
    case startTexture = "forward"
    case stopTexture = "stop"
    
    var texture: SKTexture {
        let atlas = SKTextureAtlas(named: ATLAS_NAME)
        let name: String = self.rawValue
        return atlas.textureNamed(name)
    }
}
