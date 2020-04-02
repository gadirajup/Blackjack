//
//  Game.swift
//  COpenSSL
//
//  Created by Prudhvi Gadiraju on 4/1/20.
//

import Foundation
import PerfectWebSockets
import shared

enum GameError: Error {
    case failedToSerializeMessageToJsonString(message: Message)
    case failedToFindPlayer
}

class Game {
    static let shared = Game()
    
    private var playerSocketInfo: [Player: WebSocket] = [:]
    private var playerCardInfo: [Player: [Int]] = [:]

    private var activePlayer: Player?
    
    private var players: [Player] {
        return Array(self.playerSocketInfo.keys)
    }
    
    private init() {}
    
    func playerForSocket(_ aSocket: WebSocket) -> Player? {
        var aPlayer: Player? = nil
        
        self.playerSocketInfo.forEach { (player, socket) in
            if aSocket == socket {
                aPlayer = player
            }
        }
        
        return aPlayer
    }
    
    func handlePlayerLeft(player: Player) throws {
        if self.playerSocketInfo[player] != nil {
            self.playerSocketInfo.removeValue(forKey: player)
            self.playerCardInfo.removeValue(forKey: player)
            
            let message = Message.stop()
            try notifyPlayers(message: message)
        }
    }
    
    func handleJoin(player: Player, socket: WebSocket) throws {
        if self.playerSocketInfo.count > 2 {
            return
        }
        
        self.playerSocketInfo[player] = socket
        
        if self.playerSocketInfo.count == 2 {
            try startGame()
        }
    }
    
    func handleTurn() throws {
        self.activePlayer = nextActivePlayer()!
        
        if !self.activePlayer!.hasPlayed {
            self.activePlayer!.hasPlayed = true
            let message = Message.turn(cardInfo: playerCardInfo, player: self.activePlayer!)
            try notifyPlayers(message: message)
        } else {
            // Get winner from player card info
            let totals = playerCardInfo.map { key, value in value.reduce(0, +) }
            let max = totals.max()
            let winnerIndex = totals.firstIndex(of: max!)!
            let players = Array(playerCardInfo.keys)
            let winner = players[winnerIndex]
            let message = Message.finish(winningPlayer: winner)
            try notifyPlayers(message: message)
        }
    }
    
    func handleHit(player: Player) throws {
        guard var cards = playerCardInfo[player] else {
            throw GameError.failedToFindPlayer
        }
        
        // Give card
        let card = Int.random(in: 1...13)
        cards.append(card)
        print("New Card: \(card)")
        
        playerCardInfo[player] = cards

        let message = Message.deal(player: self.activePlayer!, cardInfo: self.playerCardInfo, card: card)
        try notifyPlayers(message: message)
        
        // check if 21
        let total = cards.reduce(0, +)
        if total == 21 {
            let message = Message.finish(winningPlayer: self.activePlayer!)
            try notifyPlayers(message: message)
        } else if total > 21 {
            let message = Message.finish(winningPlayer: nextActivePlayer()!)
            try notifyPlayers(message: message)
        }
    }
    
    // MARK: - Private
    
    private func startGame() throws {
        // Shuffle Deck
        // Hand out cards
        // Wait for Player
        
        players.forEach { player in
            let card1 = Int.random(in: 1...13)
            let card2 = Int.random(in: 1...13)
            playerCardInfo[player] = [card1, card2]
        }
                
        self.activePlayer = players.randomElement()
        self.activePlayer!.hasPlayed = true
        let message = Message.turn(cardInfo: self.playerCardInfo, player: self.activePlayer!)
        try notifyPlayers(message: message)
    }
    
    private func nextActivePlayer() -> Player? {
        return self.players.filter({ $0 != self.activePlayer }).first
    }
    
    private func notifyPlayers(message: Message) throws {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(message)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw GameError.failedToSerializeMessageToJsonString(message: message)
        }
        
        self.playerSocketInfo.values.forEach({
            $0.sendStringMessage(string: jsonString, final: true, completion: {
                print("did send message: \(message.type)")
            })
        })
    }
}
