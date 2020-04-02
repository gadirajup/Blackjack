//
//  Game.swift
//  21
//
//  Created by Prudhvi Gadiraju on 4/1/20.
//  Copyright © 2020 Prudhvi Gadiraju. All rights reserved.
//

import Foundation
import shared
import CoreGraphics

class Game {
    static let shared = Game()
    private (set) var client = Client()
    private (set) var player = Player()
    private (set) var state: GameState = .disconnected
    private (set) var update: String = ""
    private var cards: [Int] = []
    
    private init() {}
    
    func start() {
        self.client.delegate = self
        self.client.connect()
    }
    
    func stop() {
        self.client.disconnect()
    }
    
    func hitMe() {
        print("Hit Me")
        self.client.hitMe(activePlayer: player)
    }
    
    func stand() {
        print("Stand")
        self.client.stand(activePlayer: player)
    }
    
    func getCards() -> String {
        return cards.reduce("") { $0 + " " + String($1) }
    }
}

// MARK: - ClientDelegate
extension Game: ClientDelegate {
    func clientDidDisconnect(error: Error?) {
        self.state = .disconnected
    }
    
    func clientDidConnect() {
        self.client.join(player: self.player)
        self.state = .connected
    }
    
    func clientDidReceiveMessage(_ message: Message) {
        switch message.type {
        case .finish:
            if let winningPlayer = message.player {
                self.state = (winningPlayer == self.player) ? .playerWon : .playerLost
            } else {
                self.state = .draw
            }
        case .stop:
            self.state = .stopped
        case .turn:
            guard let activePlayer = message.player else {
                print("no player found - this should never happen")
                return
            }
            
            if activePlayer == self.player {
                self.state = .active
            } else {
                self.state = .waiting
            }
            
            if let cards = message.cardInfo?[player] {
                print("Total: \(cards.reduce(0,+))")
                self.cards = cards
            }
        case .deal:
            guard let activePlayer = message.player else {
                print("no player found - this should never happen")
                return
            }
            
            guard let card = message.card else {
                print("no card found - this should never happen")
                return
            }
            
            if activePlayer == self.player {
                self.state = .active
                self.update = "Got a \(card)"
            } else {
                self.state = .waiting
                self.update = "a \(card) was dealt"
            }
            
            if let cards = message.cardInfo?[player] {
                print("Total: \(cards.reduce(0,+))")
                self.cards = cards
            }
        default: break
        }
    }
}
