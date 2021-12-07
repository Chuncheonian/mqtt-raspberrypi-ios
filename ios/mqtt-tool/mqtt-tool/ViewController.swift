//
//  ViewController.swift
//  mqtt-tool
//
//  Created by dykoon on 2021/10/29.
//

import UIKit
import CocoaMQTT

class ViewController: UIViewController {

  // MARK: - Properties
  var mqtt: CocoaMQTT!
  
  // MARK: - IBOutlet
  @IBOutlet weak var hostTextField: UITextField!
  @IBOutlet weak var portTextField: UITextField!
  @IBOutlet weak var connectBtn: UIButton!
  
  @IBOutlet weak var topicTextField: UITextField!
  @IBOutlet weak var payloadTextView: UITextView!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }
  
  func configure() {
    navigationItem.title = "MQTT Client"
    view.backgroundColor = UIColor(named: "bgColor")
  }
  
  // MARK: - IBAction
  
  @IBAction func connectBtnAction(_ sender: UIButton) {
    var host = hostTextField.text!
    var port = UInt16(portTextField.text!) ?? 1883
  
    var connected: Bool = false

    let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
    mqtt = CocoaMQTT(clientID: clientID, host: host, port: port)

    mqtt.keepAlive = 60
    connected = mqtt.connect()
    
    if connected {
      print("Connected to the broker")
    } else {
      print("Not connected to the broker")
    }
    mqtt.delegate = self
    
  }
  
}

// MARK: - CocoaMQTTDelegate

extension ViewController: CocoaMQTTDelegate {
  func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
    mqtt.subscribe("test/test1")
  }
  
  func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
    payloadTextView.text = message.string!
  }
  
  func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
  
  func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
    payloadTextView.text = message.string!
  }
  
  func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}
  
  func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}
  
  func mqttDidPing(_ mqtt: CocoaMQTT) {}
  
  func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
  
  func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {}
  
}
