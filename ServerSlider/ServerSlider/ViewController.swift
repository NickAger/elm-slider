//
//  ViewController.swift
//  ServerSlider
//
//  Created by Nick Ager on 21/09/2016.
//  Copyright © 2016 Rocketbox Ltd. All rights reserved.
//

import Cocoa
import HTTPServer
import WebSocketServer

class ViewController: NSViewController {
    let numberOfSliders = 10
    var sliderLabels = [NSTextField]()
    var sliders = [NSSlider]()
    var websocket: WebSocket?
    
    @IBOutlet var sliderContainerStackView: NSStackView!
    @IBOutlet var sliderNumberLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSliders()

        // startWebServer()
        
        DispatchQueue.global().async {
            self.startWebSocketServer()
        }
    }

    @IBAction func sliderChanged(_ sender: NSSlider) {
        let i = sender.tag
        
        let displayString = String(sender.intValue)
        sliderLabels[i].stringValue = displayString
        sendUpdateToClient()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

// MARK: - JSON handling
extension ViewController {
    func sendUpdateToClient() {
        let json = createJson()
        if let ws = websocket {
            DispatchQueue.global().async {
                do {
                    try ws.send(json)
                } catch {
                    print("Error sending json = \(error)")
                }
            }
        }
    }
    
    func createJson() -> String {
        let sliderValues = sliders.map { String($0.intValue) }
        
        let values = sliderValues.joined(separator: ", ")
        return "{ \"version\": 1, \"sliders\":[\(values)]}"
    }
    
    func updateSliders(values: [Int]) {
        values.enumerated().forEach { (index, value) in
            sliders[index].intValue = Int32(value)
            sliderLabels[index].stringValue = String(value)
        }
    }
}

// MARK: - view setup
extension ViewController {
    func addSliders() {
        for i in 0..<(numberOfSliders) {
            let stackView = NSStackView()
            stackView.orientation = .vertical
            
            let slider = createSlider()
            slider.tag = i
            sliders.append(slider)
            stackView.addArrangedSubview(slider)
            
            let sliderLabel = NSTextField()
            sliderLabel.isEditable = false
            sliderLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
            sliderLabels.append(sliderLabel)
            stackView.addArrangedSubview(sliderLabel)
            
            
            sliderContainerStackView.addArrangedSubview(stackView)
        }
    }
    
    func createSlider() -> NSSlider {
        let slider = NSSlider()
        slider.isVertical = true
        slider.sliderType = .linear
        slider.numberOfTickMarks = 20
        slider.minValue = 0
        slider.maxValue = 100
        slider.heightAnchor.constraint(equalToConstant: 400).isActive = true
        slider.target = self
        slider.action = #selector(sliderChanged)
        
        return slider
    }
}

// MARK: - http server
extension ViewController {
    func startWebServer() {
        let port = 8080
        let log = LogMiddleware()
        
        let router = BasicRouter { route in
            route.get("/hello") { request in
                return Response(body: "Hello, world!")
            }
        }
        
        do {
            let server = try Server(port: port, middleware: [log], responder: router)
            try server.start()
        } catch {
            print("Error = \(error)")
        }
    }
}


// MARK: - web socket server stuff
extension ViewController {
    func startWebSocketServer() {
        let server = WebSocketServer { req, ws in
            print("Connected!")
            self.websocket = ws
            ws.onText { text in
                guard let data = text.data(using: .utf8) else {
                    return
                }
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []), let jsonDict = json as? [String : Any], let sliders = jsonDict["sliders"] as? [Int] else {
                    return
                }
                DispatchQueue.main.async {
                    self.updateSliders(values: sliders)
                }
            }
            ws.onClose {(code, reason) in
                print("onClose - \(code): \(reason)")
            }
        }
        
        do {
            try Server(responder: server).start()
        } catch {
            print("Error = \(error)")
        }
    }
    
    
//    func startFromRequest () throws {
//        try Server { request in
//            return try request.webSocket { req, ws in
//                print("connected")
//                
//                ws.onBinary { data in
//                    print("data: \(data)")
//                    try ws.send(data)
//                }
//                ws.onText { text in
//                    print("data: \(text)")
//                    try ws.send(text)
//                }
//            }
//            }.start()
//    }
}
