//
//  ViewController.swift
//  mqtt-tool
//
//  Created by dykoon on 2021/10/29.
//

import UIKit
import CocoaMQTT
import Then
import SnapKit

class ViewController: UIViewController {

  // MARK: - Properties
  
  var mqtt: CocoaMQTT!
  
  private let hostLabel = UILabel().then {
    $0.text = "Host"
    $0.font = .boldSystemFont(ofSize: 18)
  }
  
  private let hostTextField = UITextField().then {
    $0.keyboardType = .decimalPad
  }
  
  private let portLabel = UILabel().then {
    $0.text = "Port"
  }
  
  private let portTextField = UITextField().then {
    $0.keyboardType = .numberPad
  }
  
  private lazy var connectButton = UIButton(type: .system).then {
    $0.backgroundColor = .black
    $0.setTitle("Connect", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
    $0.setImage(UIImage(named: "bolt"), for: .normal)
    $0.tintColor = .white
    $0.snp.makeConstraints { make in
      make.width.equalTo(311)
      make.height.equalTo(50)
    }
    $0.layer.cornerRadius = 10
    $0.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "MQTT Client"
    navigationController?.navigationBar.prefersLargeTitles = true
    view.backgroundColor = UIColor(named: "bgColor")
    layoutSubviews()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    hostTextField.addBottomBorderWithColor(color: .systemGray, height: 1.0)
    portTextField.addBottomBorderWithColor(color: .systemGray, height: 1.0)
  }
  
  // MARK: - Action
  
  @objc func didTapButton() {
    let host = hostTextField.text!
    let port = UInt16(portTextField.text!) ?? 1883

    var connected: Bool = false
    print(host, port)
    let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
    
    mqtt = CocoaMQTT(clientID: clientID, host: "localhost", port: port)
    mqtt.keepAlive = 60
    connected = mqtt.connect()
    
    if connected {
      print("Connected to the broker")
      
      let controller = PublishController()
      controller.mqtt = mqtt
      self.navigationController?.pushViewController(controller, animated: true)
    } else {
      print("Not connected to the broker")
    }
  }
  
  // MARK: - Helpers
  
  private func layoutSubviews() {
    view.addSubview(hostLabel)
    hostLabel.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(25)
      make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(32)
    }
    
    view.addSubview(hostTextField)
    hostTextField.snp.makeConstraints { make in
      make.top.equalTo(hostLabel.snp.bottom).offset(20)
      make.leading.equalTo(hostLabel.snp.leading)
      make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).offset(-32)
      make.height.equalTo(40)
    }
    
    view.addSubview(portLabel)
    portLabel.snp.makeConstraints { make in
      make.top.equalTo(hostTextField.snp.bottom).offset(25)
      make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(32)
    }
    
    view.addSubview(portTextField)
    portTextField.snp.makeConstraints { make in
      make.top.equalTo(portLabel.snp.bottom).offset(20)
      make.leading.equalTo(portLabel.snp.leading)
      make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).offset(-32)
      make.height.equalTo(40)
    }
    
    view.addSubview(connectButton)
    connectButton.snp.makeConstraints { make in
      make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(32)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-40)
      make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).offset(-32)
    }
    
  }
}

// MARK: - UITextField

extension UITextField {
  func addBottomBorderWithColor(color: UIColor, height: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(
      x: 0,
      y: self.frame.size.height - height,
      width: self.frame.size.width,
      height: height
    )
    self.layer.addSublayer(border)
  }
}
