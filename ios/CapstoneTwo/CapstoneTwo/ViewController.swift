//
//  ViewController.swift
//  CapstoneTwo
//
//  Created by dykoon on 2021/12/20.
//

import UIKit

import Alamofire
import SnapKit

class ViewController: UIViewController {

  // MARK: - Properties
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    let text = NSAttributedString(string: "반납을 위해\n킥보드를 촬영해주세요.").withLineSpacing(6)
    label.attributedText = text
    label.font = UIFont.systemFont(ofSize: 30, weight: .black)
    label.numberOfLines = 2
    return label
  }()
  
  private let subLabel: UILabel = {
    let label = UILabel()
    label.text = "아래와 같이 킥보드가 전체적으로 보이게 촬영해주세요."
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    label.textColor = .init(white: 0, alpha: 0.6)
    label.numberOfLines = 2
    return label
  }()
  
  private let kickboardIV: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.layer.cornerRadius = 15
    iv.clipsToBounds = true
    iv.image = UIImage(named: "kickboard")
    return iv
  }()
  
  private lazy var cameraBtn: UIButton = {
    let btn = UIButton(type: .system)
    btn.backgroundColor = .systemBlue
    btn.layer.cornerRadius = 13
    btn.setTitle("킥보드 촬영 시작하기", for: .normal)
    btn.setTitleColor(.white, for: .normal)
    btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    btn.addTarget(self, action: #selector(didTapCameraBtn), for: .touchUpInside)
    return btn
  }()
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.isNavigationBarHidden = true
    view.backgroundColor = .white
    
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(35)
      make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(16)
      make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).offset(16)
    }
    
    view.addSubview(subLabel)
    subLabel.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
      make.leading.equalTo(self.titleLabel.snp.leading)
      make.trailing.equalTo(self.titleLabel.snp.trailing)
    }
    
    view.addSubview(kickboardIV)
    kickboardIV.snp.makeConstraints { make in
      make.width.height.equalTo(300)
      make.center.equalToSuperview()
    }
    
    view.addSubview(cameraBtn)
    cameraBtn.snp.makeConstraints { make in
      make.height.equalTo(55)
      make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(16)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-15)
      make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).offset(-16)
    }
    
  }
  
  // MARK: - Action
  
  @objc func didTapCameraBtn() {
    showCamera()
  }
  
  func showCamera() {
    let camera = UIImagePickerController()
    camera.delegate = self
    camera.sourceType = .camera
    camera.allowsEditing = true
    camera.cameraDevice = .rear
    camera.cameraCaptureMode = .photo
    present(camera, animated: false, completion: nil)
  }
  
}


// MARK: - UIImagePickerControllerDelegate

// UIImagePickerControllerDelegate을 채택할떄는 UINavigationControllerDelegate도 같이 채택해야 한다.
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      
    guard let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage else { return }
    guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
    
    let baseURL: String = "https://ff1a-163-180-140-25.ngrok.io/fileUpload"
    let header: HTTPHeaders = ["Content-Type" : "multipart/form-data"]
  
    AF.upload(multipartFormData: { multipartFormData in
      multipartFormData.append(Data("value".utf8), withName: "key")
      multipartFormData.append(imageData, withName: "key", fileName: "image.jpeg", mimeType: "image/jpeg")
    }, to: baseURL, usingThreshold: UInt64.init(), method: .post, headers: header).responseString { response in
      let responseString: String = "\(response)"
      let startIdx: String.Index = responseString.index(responseString.startIndex, offsetBy: 9)
      let endIdx: String.Index = responseString.index(responseString.endIndex, offsetBy: -3)
      let result = String(responseString[startIdx...endIdx])
//      print("response: \(response)")
      var msg = ""
      if result == "0" {
        self.dismiss(animated: true) {
          let vc = CompleteController()
          self.navigationController?.pushViewController(vc, animated: false)
        }
      } else if result == "1" {
        msg = "킥보드가 인식이 안됩니다."
        let alert = UIAlertController(title: "재시도", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
          picker.dismiss(animated: false) {
            self.showCamera()
          }
        }
        alert.addAction(action)
        picker.present(alert, animated: true, completion: nil)
      } else {
        msg = "점자블록을 피해 주차해주세요."
        let alert = UIAlertController(title: "재시도", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
          picker.dismiss(animated: false) {
            self.showCamera()
          }
        }
        alert.addAction(action)
        picker.present(alert, animated: true, completion: nil)
      }
    }

  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
}

extension NSAttributedString {
  func withLineSpacing(_ spacing: CGFloat) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(attributedString: self)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .byTruncatingTail
    paragraphStyle.lineSpacing = spacing
    attributedString.addAttribute(
      .paragraphStyle,
      value: paragraphStyle,
      range: NSRange(location: 0, length: string.count)
    )
    return NSAttributedString(attributedString: attributedString)
  }
}
