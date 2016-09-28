//
//  ServerWebSocket.swift
//  WebSocketExperiment
//
//  Created by Nick Ager on 26/09/2016.
//  Copyright © 2016 Rocketbox Ltd. All rights reserved.
//

import Foundation

// from http://stackoverflow.com/questions/24977805/socket-server-example-with-swift

func openSocket () {
    let BUFF_SIZE = 1024
    
    func initStruct<S>() -> S {
        let struct_pointer = UnsafePointer<S>.allocate(capacity: 1)
        let struct_memory = struct_pointer.memory
        struct_pointer.destroy()
        return struct_memory
    }
    
    func sockaddr_cast(p: UnsafePointer<sockaddr_in>) -> UnsafePointer<sockaddr> {
        return UnsafePointer<sockaddr>(p)
    }
    
    func socklen_t_cast(p: UnsafePointer<Int>) -> UnsafePointer<socklen_t> {
        return UnsafePointer<socklen_t>(p)
    }
    
    var server_socket: Int32
    var client_socket: Int32
    var server_addr_size: Int
    var client_addr_size: Int
    
    var server_addr: sockaddr_in = initStruct()
    var client_addr: sockaddr_in = initStruct()
    
    var buff_rcv = Array<CChar>(repeating: 0, count: BUFF_SIZE)
    var buff_snd: String
    
    server_socket = socket(PF_INET, SOCK_STREAM, 0);
    
    if server_socket == -1
    {
        print("[Fail] Create Server Socket")
        exit(1)
    }
    else
    {
        print("[Success] Created Server Socket")
    }
    
    server_addr_size = MemoryLayout<sockaddr_in>.size
    memset(&server_addr, 0, server_addr_size);
    
    server_addr.sin_family = sa_family_t(AF_INET)
    server_addr.sin_port = UInt16(8080).bigEndian
    server_addr.sin_addr.s_addr = UInt32(0x00000000)    // INADDR_ANY = (u_int32_t)0x00000000 ----- <netinet/in.h>
    
    let bind_server = bind(server_socket, sockaddr_cast(&server_addr), socklen_t(server_addr_size))
    
    if bind_server == -1
    {
        print("[Fail] Bind Port");
        exit(1);
    }
    else
    {
        print("[Success] Binded Port");
    }
    
    if listen(server_socket, 5) == -1
    {
        print("[Fail] Listen");
        exit(1);
    }
    else
    {
        print("[Success] Listening : \(server_addr.sin_port) Port ...");
    }
    
    var n = 0
    
    while n < 1
    {
        client_addr_size = sizeof(type(of: client_addr))
        client_socket = accept(server_socket, sockaddr_cast(&client_addr), &client_addr_size)
        
        if client_socket == -1
        {
            print("[Fail] Accept Client Connection");
            exit(1);
        }
        else
        {
            print("[Success] Accepted Client : \(inet_ntoa(client_addr.sin_addr)) : \(client_addr.sin_port)");
        }
        
        read(client_socket, &buff_rcv, UInt(BUFF_SIZE))
        
        print("[Success] Received : \(buff_rcv)")
        
        buff_snd = "\(strlen(buff_rcv)) : \(buff_rcv)"
        
        write(client_socket, buff_snd.cStringUsingEncoding(NSUTF8StringEncoding)!, countElements(buff_snd) + 1)
        
        close(client_socket)
    }

}
