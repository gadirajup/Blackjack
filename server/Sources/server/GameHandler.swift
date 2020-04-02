//
//  GameHandler.swift
//  COpenSSL
//
//  Created by Prudhvi Gadiraju on 4/1/20.
//

import Foundation
import PerfectWebSockets
import PerfectHTTP
import shared

class GameHandler: WebSocketSessionHandler {

    let socketProtocol: String? = "game"
    
    func handleSession(request: HTTPRequest, socket: WebSocket) {
        print(request.serverAddress)
        socket.readStringMessage { (string, op, fin) in
            guard let string = string else {
                if let player = Game.shared.playerForSocket(socket) {
                    print("socket closed for \(player.id)")
                    
                    do {
                        try Game.shared.handlePlayerLeft(player: player)
                    } catch let error {
                        print("error: \(error)")
                    }
                }
                
                return socket.close()
            }
            
            do {
                let decoder = JSONDecoder()
                guard let data = string.data(using: .utf8) else {
                    return print("failed to covert string into data object: \(string)")
                }
                
                let message: Message = try decoder.decode(Message.self, from: data)
                try self.process(message, socket)
            } catch {
                print("Failed to decode JSON from Received Socket Message")
            }
            
            self.handleSession(request: request, socket: socket)
        }
    }
    
    func process(_ message: Message, _ socket: WebSocket) throws {
        switch message.type {
        case .join:
            guard let player = message.player else {
                return print("missing player in join message")
            }
            
            try Game.shared.handleJoin(player: player, socket: socket)
        case .hit:
            guard let player = message.player else {
                return print("missing player in hit message")
            }
            
            try Game.shared.handleHit(player: player)
        case .stand:
            try Game.shared.handleTurn()
        default:
            break
        }
    }
}
