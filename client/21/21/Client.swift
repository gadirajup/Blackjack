//
//  Client.swift
//  21
//
//  Created by Prudhvi Gadiraju on 4/1/20.
//  Copyright © 2020 Prudhvi Gadiraju. All rights reserved.
//

import Foundation
import Starscream
import shared

protocol ClientDelegate: class {
    func clientDidConnect()
    func clientDidDisconnect(error: Error?)
    func clientDidReceiveMessage(_ message: Message)
}

class Client {
    private var socket: WebSocket!
    weak var delegate: ClientDelegate?
    
    init() {
        let url = URL(string: "10.0.0.14:8181/game")!
        let request = URLRequest(url: url)
        
        self.socket = WebSocket(request: request)
        self.socket.delegate = self
    }
        
    func connect() {
        self.socket.connect()
    }
    
    func join(player: Player) {
        let message = Message.join(player: player)
        writeMessageToSocket(message)
    }
    
    func hitMe(activePlayer: Player) {
        let message = Message.hit(player: activePlayer)
        writeMessageToSocket(message)
    }
    
    func stand(activePlayer: Player) {
        let message = Message.stand(player: activePlayer)
        writeMessageToSocket(message)
    }
    
    func disconnect() {
        self.socket.disconnect()
    }
        
    private func writeMessageToSocket(_ message: Message) {
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonData = try jsonEncoder.encode(message)
            self.socket.write(data: jsonData)
        } catch let error {
            print("error: \(error)")
        }
    }
}

extension Client: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            clientDidConnect(with: headers)
        case .disconnected(let reason, let code):
            clientDidDisconnect(for: reason, with: code)
        case .text(let text):
            clientDidReceive(text: text)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            print("Received ping")
        case .pong(_):
            print("Received pong")
        case .viablityChanged(_):
            print("Received Viability Change")
        case .reconnectSuggested(_):
            print("Received Reconnect Suggested")
        case .cancelled:
            print("Received Cancelled")
        case .error(let error):
            clientDidReceive(error: error)
        }
    }
    
    func clientDidConnect(with headers: [String: String]) {
        print("Client Connected: \(headers)")
          self.delegate?.clientDidConnect()
      }
    
    func clientDidDisconnect(for reason: String, with code: UInt16) {
        print("Client Disconnected: \(reason) with code: \(code)")
        self.delegate?.clientDidDisconnect(error: nil)
    }
    
    func clientDidReceive(text: String) {
        print("Received text: \(text)")
        guard let data = text.data(using: .utf8) else {
            print("failed to convert text into data")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let message = try decoder.decode(Message.self, from: data)
            self.delegate?.clientDidReceiveMessage(message)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func clientDidReceive(error: Error?) {
        print("Error: \(String(describing: error))")
    }
}
