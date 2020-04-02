//
//  GameScene.swift
//  21
//
//  Created by Prudhvi Gadiraju on 4/1/20.
//  Copyright © 2020 Prudhvi Gadiraju. All rights reserved.
//

import SpriteKit
import GameplayKit
import shared

enum Side {
    case left
    case right
}

class GameScene: SKScene {
    private var statusLabel: SKLabelNode!
    private var cardsLabel: SKLabelNode!
    private var actionsLabel: SKLabelNode!

    
    override func sceneDidLoad() {
        Game.shared.start()
    }
    
    override func didMove(to view: SKView) {
        self.statusLabel = self.childNode(withName: "StatusLabel") as? SKLabelNode
        self.cardsLabel = self.childNode(withName: "CardsLabel") as? SKLabelNode
        self.actionsLabel = self.childNode(withName: "ActionsLabel") as? SKLabelNode
    }
    
    func touchUp(side: Side) {
        switch Game.shared.state {
        case .active:
            side == .left ? Game.shared.hitMe() : Game.shared.stand()
        case .connected, .waiting: break
        default: Game.shared.start()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch: UITouch = touches.first {
            let touchLocation = touch.location(in: self)
            if touchLocation.x < 0 {
                touchUp(side: .left)
            } else {
                touchUp(side: .right)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.statusLabel.text = Game.shared.state.message
        self.cardsLabel.text = Game.shared.getCards()
        self.actionsLabel.text = Game.shared.update
    }
}
