//
//  ViewController.swift
//  KWGraphTools
//
//  Created by Vitor Kawai Sala on 09/11/2018.
//  Copyright (c) 2018 Vitor Kawai Sala. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = SKView(frame: self.view.bounds)
        if let scene = GKScene(fileNamed: TileMapScene.sceneName) {
            
            if let sceneNode = scene.rootNode as? TileMapScene {
                sceneNode.scaleMode = .aspectFill
                
                if let view = self.view as? SKView {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
