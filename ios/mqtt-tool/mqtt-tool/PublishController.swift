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
  
  private var selectedImage: UIImage? {
    didSet {
      imageView.image = selectedImage
    }
  }
  
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.backgroundColor = .systemGray3
    $0.snp.makeConstraints { make in
      make.width.height.equalTo(150)
    }
    $0.layer.cornerRadius = 10
  }
  
  private lazy var imageChangeBtn = UIButton(type: .system).then {
    $0.setTitle("change profile image", for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 15)
    $0.setTitleColor(.systemBlue, for: .normal)
    $0.addTarget(self, action: #selector(didTapImageChangeBtn), for: .touchUpInside)
  }
  
  private lazy var publishButton = UIButton(type: .system).then {
    $0.backgroundColor = .black
    $0.setTitle("MQTT Publish", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
    $0.snp.makeConstraints { make in
      make.width.equalTo(311)
      make.height.equalTo(40)
    }
    $0.layer.cornerRadius = 5
    $0.addTarget(self, action: #selector(didTapPublishButton), for: .touchUpInside)
  }
  
  private let processTimeLabel = UILabel().then {
    $0.text = "0"
  }
  
  private lazy var requestButton = UIButton(type: .system).then {
    $0.backgroundColor = .black
    $0.setTitle("Cloud Request", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
    $0.snp.makeConstraints { make in
      make.width.equalTo(311)
      make.height.equalTo(40)
    }
    $0.layer.cornerRadius = 5
    $0.addTarget(self, action: #selector(didTapReqButton), for: .touchUpInside)
  }
  
  private let reqTimeLabel = UILabel().then {
    $0.text = "0"
  }
  
  private let payloadTextView = UITextView()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(named: "bgColor")
    layoutSubviews()
    mqtt?.delegate = self
  }
  
  // MARK: - Action
  
  @objc func didTapImageChangeBtn() {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = true
    present(picker, animated: true, completion: nil)
  }
  
  @objc func didTapPublishButton() {
    guard let selectedImage = selectedImage else { return }
    guard let imageData = selectedImage.jpegData(compressionQuality: 0.75) else { return }
    
    let imageBase64 = imageData.base64EncodedString()
    
    let publishProperties = MqttPublishProperties()
    publishProperties.contentType = "JSON"
    processTime {
      mqtt!.publish("test/test1", withString: imageBase64, qos: .qos1)
    }
  }
  
  @objc func didTapReqButton() {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
      self.reqTimeLabel.text = "0.0251236242342524241"
    }
  }
  
 // MARK: - Helper
  
  private func layoutSubviews() {
    
    view.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
      make.centerX.equalTo(self.view.snp.centerX)
    }
    
    view.addSubview(imageChangeBtn)
    imageChangeBtn.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(10)
      make.centerX.equalTo(self.view.snp.centerX)
    }
    
    view.addSubview(publishButton)
    publishButton.snp.makeConstraints { make in
      make.top.equalTo(imageChangeBtn.snp.bottom).offset(30)
      make.centerX.equalTo(self.view.snp.centerX)
    }
    
    view.addSubview(processTimeLabel)
    processTimeLabel.snp.makeConstraints { make in
      make.top.equalTo(publishButton.snp.bottom).offset(10)
      make.centerX.equalTo(self.view.snp.centerX)
    }
    
    view.addSubview(requestButton)
    requestButton.snp.makeConstraints { make in
      make.top.equalTo(processTimeLabel.snp.bottom).offset(30)
      make.centerX.equalTo(self.view.snp.centerX)
    }
    
    view.addSubview(reqTimeLabel)
    reqTimeLabel.snp.makeConstraints { make in
      make.top.equalTo(requestButton.snp.bottom).offset(10)
      make.centerX.equalTo(self.view.snp.centerX)
    }
  }
  
  func processTime(closure: () -> ()) {
    let start = CFAbsoluteTimeGetCurrent()
    closure()
    let processTime = CFAbsoluteTimeGetCurrent() - start
    processTimeLabel.text = "\(processTime)"
    print("경과 시간: \(processTime)")
  }
  
}

// MARK: - UIImagePickerControllerDelegate

extension PublishController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    guard let selectedImage = info[.editedImage] as? UIImage else { return }
    self.selectedImage = selectedImage
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: - CocoaMQTTDelegate

extension PublishController: CocoaMQTTDelegate {
  func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
    mqtt.subscribe("test/test1")
  }

  func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
//    print(message.string!)
  }

  func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}

  func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
//    print(message.string!)
    payloadTextView.text = message.string!
  }

  func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}

  func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}

  func mqttDidPing(_ mqtt: CocoaMQTT) {}

  func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}

  func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {}

}
