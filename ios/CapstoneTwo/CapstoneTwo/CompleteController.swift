//
//  CompleteController.swift
//  CapstoneTwo
//
//  Created by dykoon on 2021/12/20.
//

import UIKit
import SnapKit

class CompleteController: UIViewController {
  
  // MARK: - Properties
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "반납이 완료되었습니다."
    label.font = UIFont.systemFont(ofSize: 33, weight: .black)
    return label
  }()
  
  private let subLabel: UILabel = {
    let label = UILabel()
    label.text = "이용해주셔서 감사합니다."
    label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    label.textColor = .init(white: 0, alpha: 0.6)
    return label
  }()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    view.addSubview(subLabel)
    subLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
     view.addSubview(titleLabel)
     titleLabel.snp.makeConstraints { make in
       make.bottom.equalTo(self.subLabel.snp.top).offset(-25)
       make.centerX.equalToSuperview()
     }
    
  }
}
