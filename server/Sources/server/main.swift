//
//  main.swift
//  COpenSSL
//
//  Created by Prudhvi Gadiraju on 4/1/20.
//

import PerfectHTTP
import PerfectHTTPServer
import PerfectWebSockets
import PerfectLib

func makeRoutes() -> Routes {
    var routes = Routes()
    
    routes.add(method: .get, uri: "/game", handler: { request, response in
        WebSocketHandler(handlerProducer: { (request: HTTPRequest, protocols: [String]) -> WebSocketSessionHandler? in
            print(protocols)
            return GameHandler()
        }).handleRequest(request: request, response: response)
    })
    
    return routes
}

do {
    try HTTPServer.launch(name: "localhost", port: 8181, routes: makeRoutes())
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
