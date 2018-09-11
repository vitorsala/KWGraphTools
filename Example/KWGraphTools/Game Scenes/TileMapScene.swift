//
//  TileMapSpriteKitScene.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 27/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SpriteKit
import GameplayKit
import KWGraphTools

private enum TileMapSceneNodeName: String, NodeName {
    case Floor
    case Walls
    case Props
    case Buttons
}

private enum SelectedAction {
    case none
    case targetPoint
    case wall
    case spawnPoint
}

private enum SceneState {
    case running
    case stopped
}

private enum NodeZPosition: CGFloat {
    case background = 0
    case terrain = 1
    case properties = 2
    case agents = 3
    case ui = 1000
}

final class TileMapScene: SKScene {
    private var graph: KWGridGraph?
    private var targetGridPosition: GridPoint?
    private var spawnGridPosition: GridPoint?
    private var costLabels: [GridPoint: SKLabelNode] = [:]
    private var buttons: [Button] = []
    private var selectedAction: SelectedAction = .none
    private var poolingSystem: PoolingSystem<WalkerNode> = PoolingSystem()
    private var spawnInterval: TimeInterval = 20
    private var elapsedTimeSinceSpawn: TimeInterval = 0
    private var lastUpdate: TimeInterval = 0
    private var state: SceneState = .stopped
    
    private lazy var tmFloor: SKTileMapNode = {
        let node: SKTileMapNode = self.childNode(named: TileMapSceneNodeName.Floor) as! SKTileMapNode
        node.zPosition = NodeZPosition.terrain.rawValue
        return node
    }()
    
    private lazy var tmWalls: SKTileMapNode = {
        let node: SKTileMapNode = self.childNode(named: TileMapSceneNodeName.Walls) as! SKTileMapNode
        node.zPosition = NodeZPosition.terrain.rawValue
        return node
    }()
    
    private lazy var tmProps: SKTileMapNode = {
        let node: SKTileMapNode = self.childNode(named: TileMapSceneNodeName.Props) as! SKTileMapNode
        node.zPosition = NodeZPosition.properties.rawValue
        return node
    }()
    
    private lazy var buttonSelector: SKNode = {
        let buttonsNodes: SKReferenceNode = self.childNode(named: TileMapSceneNodeName.Buttons) as! SKReferenceNode
        let node = buttonsNodes.baseChildrens()!.childNode(named: TopMenuButtonsName.Selector)!
        node.zPosition = NodeZPosition.ui.rawValue + 1
        return node
    }()
    
    override func update(_ currentTime: TimeInterval) {
        guard self.targetGridPosition != nil && self.state == .running else { return }
        let delta = currentTime - self.lastUpdate
        self.lastUpdate = currentTime
        self.elapsedTimeSinceSpawn += delta
        if self.elapsedTimeSinceSpawn > self.spawnInterval {
            self.elapsedTimeSinceSpawn = 0
            self.summonAgents()
        }
    }
    
    override func sceneDidLoad() {
        self.graph = tmFloor.generateGridGraph(diagonalAllowed: false)
        self.graph?.addObstacle(fromTileMap: tmWalls)
        self.setupButtons()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch: UITouch = touches.first else { return }
        let sceneNodes = self.nodes(at: touch.location(in: self))
        if let btn = sceneNodes.first(where: { return ($0 as? Button) != nil }) as? Button {
            btn.execute(buttonEvent: .began)
        } else {
            let location = touch.location(in: self.tmFloor)
            let gridPoint = GridPoint(x: self.tmFloor.tileColumnIndex(fromPosition: location),
                                      y: self.tmFloor.tileRowIndex(fromPosition: location))
            self.touchAction(location: gridPoint)
        }
    }
}

extension TileMapScene {
    private func touchAction(location: GridPoint) {
        self.costLabels.forEach { $1.fontColor = UIColor.black }
        self.clearAgents()
        switch self.selectedAction {
        case .spawnPoint:
            guard self.isPlaceable(location: location) else { return }
            self.spawnGridPosition = location
            #if LABELED
            self.plotPath(from: location)
            #endif
            
        case .targetPoint:
            self.setTarget(atLocation: location)
            
        case .wall:
            self.setWall(atLocation: location)
            
        default:
            return
        }
        #if LABELED
        if self.selectedAction != .spawnPoint {
            self.updateCostLabels()
            if let spawnPosition = self.spawnGridPosition {
                self.plotPath(from: spawnPosition)
            }
        }
        #endif
        self.elapsedTimeSinceSpawn = self.spawnInterval
    }
    
    private func setTarget(atLocation location: GridPoint) {
        guard self.isPlaceable(location: location) else { return }
        if let targetPoint = self.targetGridPosition {
            self.tmProps.setTileGroup(nil, forColumn: targetPoint.x, row: targetPoint.y)
        }
        if let tile: SKTileGroup = self.tmProps.tileSet.tileGroup(named: PropsSet.stub_01) {
            self.tmProps.setTileGroup(tile, forColumn: location.x, row: location.y)
        }
        self.targetGridPosition = location
        self.graph?.generatePaths(convergingToPoint: vector_int2(point: location))
    }
    
    private func setWall(atLocation location: GridPoint) {
        if self.tmWalls.haveTile(atColumn: location.x, row: location.y) {
            self.tmWalls.setTileGroup(nil, forColumn: location.x, row: location.y)
            self.graph?.removeObstacle(atGridPosition: vector_int2(point: location))
        } else {
            if self.targetGridPosition == nil {
                if let tile: SKTileGroup = self.tmWalls.tileSet.tileGroup(named: WallSet.wall_orange) {
                    self.tmWalls.setTileGroup(tile, forColumn: location.x, row: location.y)
                }
                self.graph?.addObstacle(atGridPosition: vector_int2(point: location))
            } else if let spawnPoint = self.targetGridPosition, location != spawnPoint {
                if let tile: SKTileGroup = self.tmWalls.tileSet.tileGroup(named: WallSet.wall_orange) {
                    self.tmWalls.setTileGroup(tile, forColumn: location.x, row: location.y)
                }
                self.graph?.addObstacle(atGridPosition: vector_int2(point: location))
            } else {
                return
            }
        }
        if let targetPosition = self.targetGridPosition {
            self.graph?.generatePaths(convergingToPoint: vector_int2(point: targetPosition))
        }
    }
    
    private func plotPath(from location: GridPoint) {
        guard let path = self.graph?.findPath(from: vector_int2(x: Int32(location.x), y: Int32(location.y))) else { return }
        let gridPoints = path.map { return GridPoint(x: Int($0.x), y: Int($0.y)) }
        gridPoints.forEach { self.costLabels[$0]?.fontColor = UIColor.red }
    }
    
    private func isPlaceable(location: GridPoint) -> Bool {
        return !self.tmWalls.haveTile(atColumn: location.x, row: location.y) &&
            self.tmFloor.haveTile(atColumn: location.x, row: location.y)
    }
}

extension TileMapScene {
    private func summonAgents() {
        guard let graph = self.graph else { return }
        for y in 0..<self.tmFloor.numberOfRows {
            for x in 0..<self.tmFloor.numberOfColumns {
                if graph.haveValidPath(from: vector_int2(Int32(x), Int32(y))),
                    self.isPlaceable(location: GridPoint(x: x, y: y)) {
                    
                    let node = self.poolingSystem.pop()
                    node.zPosition = NodeZPosition.agents.rawValue
                    node.gridPoint = GridPoint(x: x, y: y)
                    self.tmProps.addChild(node)
                    node.position = self.tmProps.centerOfTile(atColumn: x, row: y)
                    node.followPath(gridGraph: graph) {
                        node.removeAllActions()
                        self.poolingSystem.push(node: node)
                    }
                }
            }
        }
    }
    
    private func clearAgents() {
        let agents = self.tmProps.children.compactMap { return $0 as? WalkerNode }
        agents.forEach { self.poolingSystem.push(node: $0) }
    }
}

extension TileMapScene {
    private func setupButtons() {
        let buttonNode = (self.childNode(named: TileMapSceneNodeName.Buttons) as! SKReferenceNode).baseChildrens()!
        let spawnButton: Button = buttonNode.childNode(named: TopMenuButtonsName.SpawnButton) as! Button
        spawnButton.actions[.began] = { [unowned self] button in
            self.selectedAction = .spawnPoint
            self.buttonSelector.position = button.position
        }
        let wallButton: Button = buttonNode.childNode(named: TopMenuButtonsName.WallButton) as! Button
        wallButton.actions[.began] = { [unowned self] button in
            self.selectedAction = .wall
            self.buttonSelector.position = button.position
        }
        let targetButton: Button = buttonNode.childNode(named: TopMenuButtonsName.TargetButton) as! Button
        targetButton.actions[.began] = { [unowned self] button in
            self.selectedAction = .targetPoint
            self.buttonSelector.position = button.position
        }
        let fastForwardButton: Button = buttonNode.childNode(named: TopMenuButtonsName.FastForwardButton) as! Button
        fastForwardButton.actions[.began] = { [unowned self] button in
            self.elapsedTimeSinceSpawn = self.spawnInterval
        }
        let controlButton: Button = buttonNode.childNode(named: TopMenuButtonsName.StartStopButton) as! Button
        controlButton.actions[.began] = { [unowned self] button in
            switch self.state {
            case .running:
                self.state = .stopped
                button.texture = TopMenuButtonTextures.startTexture.texture
            case .stopped:
                self.state = .running
                button.texture = TopMenuButtonTextures.stopTexture.texture
            }
        }
        self.buttons = [spawnButton, wallButton, targetButton, fastForwardButton, controlButton]
        self.buttons.forEach { $0.zPosition = NodeZPosition.ui.rawValue }
    }
}

#if LABELED
extension TileMapScene {
    private func updateCostLabels() {
        for column in 0..<self.tmFloor.numberOfColumns {
            for row in 0..<self.tmFloor.numberOfRows {
                let gridPosition: GridPoint = GridPoint(x: column, y: row)
                if self.isPlaceable(location: gridPosition) {
                    let cost: Float = self.graph?.nodeAtGridPosition(x: column, y: row)?.accumulatedCost ?? 0
                    self.costLabel(atGridPoint: gridPosition, cost: cost)
                } else {
                    let label = self.costLabels[gridPosition]
                    label?.isHidden = true
                }
            }
        }
    }
    
    private func costLabel(atGridPoint point: GridPoint, cost: Float) {
        if let costLabel = self.costLabels[point] {
            costLabel.isHidden = false
            costLabel.text = (self.graph?.haveValidPath(from: vector_int2(point: point)) ?? false ? "\(cost)" : "")
        } else {
            let scenePosition: CGPoint = self.tmFloor.centerOfTile(atColumn: point.x, row: point.y)
            
            let costLabel: SKLabelNode = self.createLabel(text: "\(cost)")
            costLabel.position = scenePosition
            
            self.tmProps.addChild(costLabel)
            
            self.costLabels[point] = costLabel
        }
    }
    
    private func createLabel(text: String) -> SKLabelNode {
        let costLabel: SKLabelNode = SKLabelNode(text: text)
        costLabel.fontColor = UIColor.black
        costLabel.zPosition = NodeZPosition.properties.rawValue
        costLabel.fontSize = 40
        costLabel.fontName = UIFont.boldSystemFont(ofSize: 40).fontName
        costLabel.horizontalAlignmentMode = .center
        costLabel.verticalAlignmentMode = .center
        return costLabel
    }
}
#endif