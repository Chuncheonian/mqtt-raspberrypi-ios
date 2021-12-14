//
//  PublishController.swift
//  mqtt-tool
//
//  Created by dykoon on 2021/12/15.
//

import UIKit
import CocoaMQTT

class PublishController: UIViewController {
  
  // MARK: - Properties
  
  var mqtt: CocoaMQTT?
  
  private let payloadTextView = UITextView()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(named: "bgColor")
    layoutSubviews()
    mqtt?.delegate = self
  }
  
 // MARK: - Helper
  
  private func layoutSubviews() {
    view.addSubview(payloadTextView)
    payloadTextView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(25)
      make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(32)
      make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).offset(-32)
      make.height.equalTo(50)
    }
  }
}

// MARK: - CocoaMQTTDelegate

extension PublishController: CocoaMQTTDelegate {
  func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
    mqtt.subscribe("test/test1")
  }

  func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
    print(message.string!)
  }

  func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}

  func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
    print(message.string!)
    payloadTextView.text = message.string!
  }

  func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}

  func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}

  func mqttDidPing(_ mqtt: CocoaMQTT) {}

  func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}

  func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {}

}
