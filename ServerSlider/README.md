# Searching for Socket servers on Mac

| Library                |language | Comments                                                |
|------------------------|---------|---------------------------------------------------------|
|[SocketKit](https://github.com/YaxinCheng/SocketKit)|Swift 3|Appears to be client only, wrapped as a Cocoapod - see SwiftSocketsExperiment|
|[SwiftSockets](http://www.alwaysrightinstitute.com/SwiftSockets/)|Swift 2/3?|Yet to investigate: A simple GCD based socket wrapper for Swift."SwiftSockets is kind of a demo on how to integrate Swift with raw C APIs. More for stealing Swift coding ideas than for actually using the code in a real world project. In most real world Swift apps you have access to Cocoa, use it. If you need a Swift networking toolset for the server side, consider: Noze.io."|
|[libwebsockets](https://libwebsockets.org)|C|Libwebsockets is a lightweight pure C library built to use minimal CPU and memory resources, and provide fast throughput in both directions as client or server.|
|[BLWebSocketsServer](https://github.com/benlodotcom/BLWebSocketsServer)|Objective-C|BLWebSocketsServer is a lightweight websockets server for iOS built around libwebsockets. The server suports both synchronous requests and push.|
|[SwiftFire](https://github.com/Swiftrien/Swiftfire), including [SwifterSockets](https://github.com/Swiftrien/SwifterSockets)|Swift 2/3?|A collection of socket utilities in pure Swift. SwifterSockets is part of the 4 packages that make up the Swiftfire webserver|
|[Socket programming in Swift](http://swiftrien.blogspot.co.uk/2015/11/socket-programming-in-swift-part-5.html)|Swift 3|Series of blog posts about socket programming in Swift, from SwiftFire|
|[Stackoverflow - Socket Server Example with Swift](http://stackoverflow.com/questions/24977805/socket-server-example-with-swift)|Swift 2| .. |
|[Writing a socket server in C#](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API/Writing_WebSocket_server)|C#|Example of building websockets on top of unix sockets|
|[SwiftWebSocket](https://github.com/tidwall/SwiftWebSocket)|Swift 2/3|couldn't get to work|
|[Zewo/WebSocket](https://github.com/Zewo/WebSocket)|Swift 3|Worth another look? This module contains no networking. To create a WebSocket Server, see WebSocketServer. To create a WebSocket Client, see WebSocketClient.|
|[PerfectExample-WebSocketsServer](https://github.com/PerfectlySoft/PerfectExample-WebSocketsServer)|Swift 2|Large webserver that seemed overkill|

## Next Steps
* [Zewo/WebSocket](https://github.com/Zewo/WebSocket)
* [SwiftSockets](http://www.alwaysrightinstitute.com/SwiftSockets/)

## Using [Zewo/WebSocket](https://github.com/Zewo/WebSocket)

To install:

First install `Zewo/WebSocketServer`:
```bash
$ git clone https://github.com/Zewo/WebSocketServer.git
$ swift package generate-xcodeproj
```

open and build `./WebSocketServer.xcodeproj`

Then install `Zewo/HTTPServer`:
```bash
$ git clone https://github.com/Zewo/HTTPServer.git
$ swift package generate-xcodeproj
```
