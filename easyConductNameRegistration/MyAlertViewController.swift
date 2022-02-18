//
//  MyAlertViewController.swift
//  easyConductNameRegistration
//
//  Created by ＭacR7 on 2022/1/25.
//

import UIKit

class MyAlertViewController: UIViewController {

    //螢幕寬高
    var UIWidth = UIScreen.main.bounds.width
    var UIheight = UIScreen.main.bounds.height
    //
    var realNameImformation = ""
    //彈出視窗
    var myAlertView:UIView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        
        myAlertView = UIView()
        if let myAlertView = myAlertView {
            myAlertView.frame = CGRect(origin: CGPoint(x: UIWidth*0.05, y: UIheight/2-UIWidth*0.45), size: CGSize(width: UIWidth*0.9, height: UIWidth*0.9))
            myAlertView.backgroundColor = .white
            myAlertView.layer.cornerRadius = UIWidth/10
            myAlertView.alpha = 1
            view.addSubview(myAlertView)
        }
        let closeButton:UIButton = {
            let btn = UIButton()
            btn.frame = CGRect(x: UIWidth/2-50, y:UIWidth/2-30 , width: 100, height: 60)
            btn.setTitle("關閉", for: .normal)
            btn.backgroundColor = .link
            btn.addTarget(self, action: #selector(closeView(_:)), for: .touchUpInside)
            return btn
        }()
        myAlertView?.addSubview(closeButton)

        print("實聯制資訊：\(realNameImformation)")
        
        
    }
    
    @IBAction func closeView(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}

