//
//  WebSocket.swift
//  WebSocketExperiment2
//
//  Created by Nick Ager on 26/09/2016.
//  Copyright © 2016 Rocketbox Ltd. All rights reserved.
//

import Foundation

// from http://swiftrien.blogspot.co.uk/2015/10/socket-programming-in-swift-part-1.html

func sockaddrDescription(addr: UnsafePointer<sockaddr>) -> (String?, String?) {
    
    var host : String?
    var service : String?
    
    var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
    var serviceBuffer = [CChar](repeating: 0, count: Int(NI_MAXSERV))
    
    if getnameinfo(
        addr,
        socklen_t(addr.pointee.sa_len),
        &hostBuffer,
        socklen_t(hostBuffer.count),
        &serviceBuffer,
        socklen_t(serviceBuffer.count),
        NI_NUMERICHOST | NI_NUMERICSERV)
        
        == 0 {
        
        host = String(cString: hostBuffer)
        service = String(cString: serviceBuffer)
    }
    return (host, service)
    
}


func doIt () {
    let servicePortNumber = "3333"
    let applicationInDebugMode = true
    
    // General purpose status variable, used to detect error returns from socket functions
    
    var status: Int32 = 0
    
    // ==================================================================
    // Retrieve the information necessary to create the socket descriptor
    // ==================================================================
    
    // Protocol configuration, used to retrieve the data needed to create the socket descriptor
    
    var hints = addrinfo(
        ai_flags: AI_PASSIVE,       // Assign the address of the local host to the socket structures
        ai_family: AF_UNSPEC,       // Either IPv4 or IPv6
        ai_socktype: SOCK_STREAM,   // TCP
        ai_protocol: 0,
        ai_addrlen: 0,
        ai_canonname: nil,
        ai_addr: nil,
        ai_next: nil)
    
    // For the information needed to create a socket (result from the getaddrinfo)
    var servinfo: UnsafeMutablePointer<addrinfo>? = nil
    
    // Get the info we need to create our socket descriptor
    
    status = getaddrinfo(
        nil,                        // Any interface
        servicePortNumber,          // The port on which will be listenend
        &hints,                     // Protocol configuration as per above
        &servinfo)                  // The created information
    
    
    // Cop out if there is an error
    if status != 0 {
        var strError: String
        if status == EAI_SYSTEM {
            strError = String(validatingUTF8: strerror(errno)) ?? "Unknown error code"
        } else {
            strError = String(validatingUTF8: gai_strerror(status)) ?? "Unknown error code"
        }
        print(strError)
        return
    }
    
    
    // Print a list of the found IP addresses
    
    if applicationInDebugMode {
        var info = servinfo
        while info != nil {
            let (clientIp, service) = sockaddrDescription(addr: info!.pointee.ai_addr)
            let message = "HostIp: " + (clientIp ?? "?") + " at port: " + (service ?? "?")
            print(message)
            info = info!.pointee.ai_next
        }   
        
    }
    
    // http://swiftrien.blogspot.co.uk/2015/10/socket-programming-in-swift-part-2.html
    
    // ============================
    // Create the socket descriptor
    // ============================
    
    let socketDescriptor = socket(
        servinfo!.pointee.ai_family,      // Use the servinfo created earlier, this makes it IPv4/IPv6 independant
        servinfo!.pointee.ai_socktype,    // Use the servinfo created earlier, this makes it IPv4/IPv6 independant
        servinfo!.pointee.ai_protocol)    // Use the servinfo created earlier, this makes it IPv4/IPv6 independant
    
    print("Socket value: \(socketDescriptor)")

    // Cop out if there is an error
    
    if socketDescriptor == -1 {
        let strError = String(utf8String: strerror(errno)) ?? "Unknown error code"
        let message = "Socket creation error \(errno) (\(strError))"
        freeaddrinfo(servinfo)
        print(message)
        return
    }
    
    // ========================================================================
    // Set the socket options (specifically: prevent the "socket in use" error)
    // ========================================================================
    
    var optval: Int = 1; // Use 1 to enable the option, 0 to disable
    
    status = setsockopt(
        socketDescriptor,               // The socket descriptor of the socket on which the option will be set
        SOL_SOCKET,                     // Type of socket options
        SO_REUSEADDR,                   // The socket option id
        &optval,                        // The socket option value
        socklen_t(MemoryLayout<Int>.size))    // The size of the socket option value
    
    if status == -1 {
        let strError = String(utf8String: strerror(errno)) ?? "Unknown error code"
        let message = "Setsockopt error \(errno) (\(strError))"
        freeaddrinfo(servinfo)
        close(socketDescriptor)         // Ignore possible errors
        print(message)
        return
    }
   
    // http://swiftrien.blogspot.co.uk/2015/11/socket-programming-in-swift-part-3-bind.html
    
    let maxNumberOfConnectionsBeforeAccept: Int32 = 20
    
    // ====================================
    // Bind the socket descriptor to a port
    // ====================================
    
    status = bind(
    socketDescriptor,               // The socket descriptor of the socket to bind
    servinfo!.pointee.ai_addr,        // Use the servinfo created earlier, this makes it IPv4/IPv6 independant
    servinfo!.pointee.ai_addrlen)     // Use the servinfo created earlier, this makes it IPv4/IPv6 independant
    
    print("Status from binding: \(status)")
    
    
    // Cop out if there is an error
    
    if status != 0 {
        let strError = String(utf8String: strerror(errno)) ?? "Unknown error code"
        let message = "Binding error \(errno) (\(strError))"
        freeaddrinfo(servinfo)
        close(socketDescriptor)         // Ignore possible errors
        print (message)
        return
    }
    
    
    // ===============================
    // Don't need the servinfo anymore
    // ===============================
    
    freeaddrinfo(servinfo)
    
    
    // ========================================
    // Start listening for incoming connections
    // ========================================
    
    status = listen(
        socketDescriptor,                     // The socket on which to listen
        maxNumberOfConnectionsBeforeAccept)   // The number of connections that will be allowed before they are accepted
    
    print("Status from listen: " + status.description)
    
    
    // Cop out if there are any errors
    
    if status != 0 {
        let strError = String(utf8String: strerror(errno)) ?? "Unknown error code"
        let message = "Listen error \(errno) (\(strError))"
        print(message)
        close(socketDescriptor)         // Ignore possible errors
        return
        
    }
    
    // http://swiftrien.blogspot.co.uk/2015/11/socket-programming-in-swift-part-4-sw.html
    
    // Mock up code
    
    // =================================================
    // Initialize the port on which we will be listening
    // =================================================
    
    let httpSocketDescriptor = initServerSocket(
        servicePortNumber: ap_HttpServicePortNumber,
        maxNumberOfConnectionsBeforeAccept: ap_MaxNumberOfHttpConnectionsWaitingToBeAccepted)
    
    if httpSocketDescriptor == nil { applicationExit() } // Log entries should have been made
    
    
    // ===========================================================================
    // Keep on accepting connection requests until a fatal error or a stop request
    // ===========================================================================
    
    stopAcceptThread = false
    
    let acceptQueue: DispatchQueue = DispatchQueue(
        label: "Accept queue",
        attributes: [.serial, .qosUserInteractive])
    
    acceptQueue.async() { acceptConnectionRequests(httpSocketDescriptor!) }

    // http://swiftrien.blogspot.co.uk/2015/11/socket-programming-in-swift-part-4.html
    // (PS: You could place this code after the listening call previously in this series, but it really should reside in its own loop as has been discussed.)

    // Incoming connections will be executed in this queue (in parallel)
    
    let connectionQueue = DispatchQueue(
        label: "ConnectionQueue",
        attributes: [.concurrent]
    )
    
    
    // ========================
    // Start the "endless" loop
    // ========================
    
    ACCEPT_LOOP: while true {
        
        
        // =======================================
        // Wait for an incoming connection request
        // =======================================
        
        var connectedAddrInfo = sockaddr(sa_len: 0, sa_family: 0, sa_data: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        var connectedAddrInfoLength = socklen_t(MemoryLayout<sockaddr>.size)
        
        let requestDescriptor = accept(socketDescriptor, &connectedAddrInfo, &connectedAddrInfoLength)
        
        if requestDescriptor == -1 {
            let strerr = String(utf8String: strerror(errno)) ?? "Unknown error code"
            let message = "Accept error \(errno) " + strerr
            print(message)
            // #FEATURE# Add code to cop out if errors occur continuously
            continue
        }
        
        
        let (ipAddress, servicePort) = sockaddrDescription(addr: &connectedAddrInfo)
        
        let message = "Accepted connection from: " + (ipAddress ?? "nil") + ", from port:" + (servicePort ?? "nil")
        print(message)
        
        
        // ==========================================================================
        // Request processing of the connection request in a different dispatch queue
        // ==========================================================================
        
        connectionQueue.async() { receiveAndDispatch(socket: requestDescriptor)}
    }
}

func receiveAndDispatch(socket: Int32) {
    
    let dataProcessingQueue = DispatchQueue.main
    
    let bufferSize = 100*1024 // Application dependant
    var requestBuffer: Array<UInt8> = Array(repeating: 0, count: bufferSize)
    var requestLength: Int = 0
    
    func requestIsComplete() -> Bool {
        // This function should find out if all expected data was received and return 'true' if it did.
        return true
    }
    
    func processData(data: Data) {
        // This function should do something with the received data
    }
    
    // =========================================================================================
    // This loop stays active as long as there is data left to receive, or until an error occurs
    // =========================================================================================
    
    RECEIVER_LOOP: while true {
        
        
        // =====================================================================================
        // Use the select API to wait for anything to happen on our client socket only within
        // the timeout period
        // =====================================================================================
        
        let numOfFd:Int32 = socket + 1
        var readSet:fd_set = fd_set(fds_bits: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        var timeout:timeval = timeval(tv_sec: 10, tv_usec: 0)
        
        SwifterSockets.fdSet(socket, set: &readSet)
        let status = select(numOfFd, &readSet, nil, nil, &timeout)
        
        // Because we only specified 1 FD, we do not need to check on which FD the event was received
        
        
        // =====================================================================================
        // In case of a timeout, close the connection
        // =====================================================================================
        
        if status == 0 {
            
            let message = "Timeout during select."
            print(message)
            close(socket)
            break RECEIVER_LOOP
        }
        
        
        // =====================================================================================
        // In case of an error, close the connection
        // =====================================================================================
        
        if status == -1 {
            
            let errString = String(utf8String: strerror(errno)) ?? "Unknown error code"
            let message = "Error during select, message = \(errno) (\(errString))"
            print(message)
            close(socket)
            break RECEIVER_LOOP
        }
        
        
        // =====================================================================================
        // Use the recv API to see what happened
        // =====================================================================================
        
        let bytesRead = recv(
            socket,
            &requestBuffer[requestLength],
            bufferSize,
            0)
        
        
        // =====================================================================================
        // In case of an error, close the connection
        // =====================================================================================
        
        if bytesRead == -1 {
            
            let errString = String(utf8String: strerror(errno)) ?? "Unknown error code"
            let message = "Recv error = \(errno) (\(errString))"
            print(message)
            
            // The connection might still support a transfer, it could be tried to get a message to the client. Not in this example though.
            
            close(socket)
            break RECEIVER_LOOP
        }
        
        
        // =====================================================================================
        // If the client closed the connection, close our end too
        // =====================================================================================
        
        if bytesRead == 0 {
            
            let message = "Client closed connection"
            print(message)
            close(socket)
            break RECEIVER_LOOP
        }
        
        
        // =====================================================================================
        // If the request is completely received, dispatch it to the dispatchQueue
        // =====================================================================================
        
        let message = "Received \(bytesRead) bytes from the client"
        print(message)
        
        requestLength = requestLength + bytesRead
        
        if requestIsComplete() {
            
            let receivedData = Data(bytes: requestBuffer[0 ... requestLength])
            dataProcessingQueue.async() { processData(data: receivedData) }
            
            close(socket)
            break RECEIVER_LOOP
        }
    }
    
}
