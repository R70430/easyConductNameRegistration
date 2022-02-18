//
//  ViewController.swift
//  easyConductNameRegistration
//
//  Created by ＭacR7 on 2022/1/25.
//

import AVFoundation
import MessageUI
import UIKit


class ViewController: UIViewController {
    //螢幕寬高
    var UIWidth = UIScreen.main.bounds.width
    var UIheight = UIScreen.main.bounds.height
    
    //同行人數
    var numberOfPeople = 1
    var peoples = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    //UI
    var numberOfPeopleButton:UIButton?//同行人數按鈕
    var QRcodeWaterMarkImageView:UIImageView?//QRCode浮水印
    var QRcodeScanView:UIView?//掃描紅框
    var numberOfPeoplePicker:UIPickerView?//同行人數選擇器
    
//MARK: - 禁止旋轉
    override var shouldAutorotate : Bool {
        return false
    }
//MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //設定UI
        UISetting()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //先檢查相機權限
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined://還沒決定
            print("還沒決定 notDetermined")
            AVCaptureDevice.requestAccess(for: .video) { success in
                guard success == true else {return}
                //從相機取得影像
                self.getVideoFromCamera()
                //開始擷取影片
                self.captureSession.startRunning()
            }
            break
            
        case .denied,.restricted:
            print("已拒絕給予相機權限")
            let myAlert = UIAlertController (title: "相機啟用失敗", message: "相機服務未啟用", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "去設定", style: .default) { (_) -> Void in
                guard
                    let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                else {return}
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("開啟設定: \(success)") // Prints true
                    })
                }
            }
            myAlert.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "確認", style: .default, handler: nil)
            myAlert.addAction(cancelAction)
            present(myAlert, animated: true, completion: nil)
            break
            
        case .authorized:
            print("已同意給予相機權限")
            //從相機取得影像
            self.getVideoFromCamera()
            //開始擷取影片
            self.captureSession.startRunning()
            break
            
        default:
            let myAlert = UIAlertController (title: "相機啟用失敗", message: "相機服務未啟用", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "去設定", style: .default) { (_) -> Void in
                guard
                    let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                else {return}
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("開啟設定: \(success)") // Prints true
                    })
                }
            }
            myAlert.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "確認", style: .default, handler: nil)
            myAlert.addAction(cancelAction)
            present(myAlert, animated: true, completion: nil)
            break
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//MARK: - MyFunc
    
    //設定UI
    func UISetting(){
        
        //浮水印
        QRcodeWaterMarkImageView = UIImageView()
        if let QRcodeWaterMarkImageView = QRcodeWaterMarkImageView {
            QRcodeWaterMarkImageView.frame = CGRect(x: UIWidth/2-UIWidth*0.4, y: UIheight/2-UIWidth*0.4, width: UIWidth*0.8, height: UIWidth*0.8)
            QRcodeWaterMarkImageView.image = UIImage(named: "imgQRCodeSimple")
            QRcodeWaterMarkImageView.alpha = 0.1
            QRcodeWaterMarkImageView.clipsToBounds = true
            QRcodeWaterMarkImageView.layer.cornerRadius = 30
            QRcodeWaterMarkImageView.backgroundColor = .clear
            view.addSubview(QRcodeWaterMarkImageView)
        }
        
        //同行人數選擇鈕
        numberOfPeopleButton = UIButton()
        if let numberOfPeopleButton = numberOfPeopleButton {
            numberOfPeopleButton.frame = CGRect(
                origin: CGPoint(
                    x:UIWidth/2-UIWidth*0.4,
                    y: UIheight-UIWidth/6.25-UIheight*0.1),
                size: CGSize(width: UIWidth*0.8, height: UIWidth/6.25))
            numberOfPeopleButton.backgroundColor = .gray
            numberOfPeopleButton.setImage(UIImage(systemName: "person.2.fill"), for: .normal)
            numberOfPeopleButton.imageView?.tintColor = .green
            numberOfPeopleButton.setTitle("\(numberOfPeople)", for: .normal)
            numberOfPeopleButton.titleLabel?.font = .boldSystemFont(ofSize: 25)
            numberOfPeopleButton.layer.cornerRadius = 20
            numberOfPeopleButton.alpha = 0.7
            numberOfPeopleButton.addTarget(self, action: #selector(numberOfPeopleAction(_:)), for: .touchUpInside)
            view.addSubview(numberOfPeopleButton)
            
        }
        
        //同行人數選擇器
        numberOfPeoplePicker = UIPickerView()
        if let numberOfPeoplePicker = numberOfPeoplePicker {
            numberOfPeoplePicker.frame = CGRect(
                x: 0, y: UIheight-UIWidth/2, width: UIWidth, height: UIWidth/2)
            numberOfPeoplePicker.backgroundColor = .gray
            numberOfPeoplePicker.layer.cornerRadius = UIWidth/10
            numberOfPeoplePicker.alpha = 0.7
            numberOfPeoplePicker.delegate = self
            numberOfPeoplePicker.dataSource = self
            numberOfPeoplePicker.isHidden = true
            view.addSubview(numberOfPeoplePicker)
            
        }
        
        //設定掃描框
        QRcodeScanView = UIView()
        if let QRcodeScanView = QRcodeScanView {
            QRcodeScanView.layer.borderColor = UIColor.red.cgColor
            QRcodeScanView.layer.borderWidth = 2
            view.addSubview(QRcodeScanView)
        }
    }
    
    //發送SNS
    func sendSMS(Message:String){
        
        //取得Recipient
        let recipientList = ["\(getRecipient(realNameInformation: Message))"]
        //取得訊息內容
        var mySMSText = getSMSText(realNameInformation: Message)
        
        //如果人數不是1人 加上人數
        if numberOfPeople != 1 {
            mySMSText = "\(mySMSText)+\(numberOfPeople)"
        }
        //檢查設備是否可以發送簡訊，之後執行
        if MFMessageComposeViewController.canSendText(){
            
            let controller = MFMessageComposeViewController()
            //設定委派
            controller.messageComposeDelegate = self
            //收件人列表
            controller.recipients = recipientList
            //簡訊內容
            controller.body = mySMSText
            //執行
            self.present(controller, animated: true, completion: nil)

        }else{
            let alert = UIAlertController(title: "訊息", message: "這台設備沒有簡訊發送功能，因此無法發送簡訊。", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "關閉", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    //取得發送對象
    func getRecipient(realNameInformation:String) -> String{
        let delStart = realNameInformation[realNameInformation.range(of: "SMSTO:")!.upperBound...]
        let delEnd = delStart[..<realNameInformation.range(of: ":場所代碼")!.lowerBound]
        print("送給\(delEnd)")
        return String(delEnd)
    }
    //取得SMS內文
    func getSMSText(realNameInformation:String) -> String{
        let delStart = realNameInformation[realNameInformation.range(of: "SMSTO:1922:")!.upperBound...]
        print("內容：\(delStart)")
        return String(delStart)
    }

    //從相機取得影像
    func getVideoFromCamera(){

        //取得後置鏡頭來擷取影片
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        else{
            print("找不到後置鏡頭")
            return
        }
        
        do{
            //使用 後置鏡頭 來取得 AVCaptureDeviceInput 類別的實例
            let input = try AVCaptureDeviceInput(device: captureDevice)
            //在 captureSession 上，設定輸入裝置為 input
            captureSession.addInput(input)
            //初始化一個 AVCaptureMetadataOutput 物件為 session 的輸出裝置
            let captureMetadataOutput = AVCaptureMetadataOutput()
            //設定委派
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //加入Session中
            captureSession.addOutput(captureMetadataOutput)
            //設定Type為QRCode
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

            
            let videoPreviewLayerModel:AVCaptureVideoPreviewLayer = {
                let myModel = AVCaptureVideoPreviewLayer(session: captureSession)
                myModel.videoGravity = .resizeAspectFill
                myModel.frame = UIScreen.main.bounds
                
                return myModel
            }()
            videoPreviewLayer = videoPreviewLayerModel
            view.layer.addSublayer(videoPreviewLayer)
            
            view.bringSubviewToFront(QRcodeWaterMarkImageView!)
            view.bringSubviewToFront(numberOfPeopleButton!)
            view.bringSubviewToFront(numberOfPeoplePicker!)
            view.bringSubviewToFront(QRcodeScanView!)//放到最上方
            
            

        }catch{
            print("發生錯誤，錯誤內容為：\n『\(error)』")
        }
    }
    
    @IBAction func numberOfPeopleAction(_ sender:UIButton){
        numberOfPeoplePicker?.isHidden = false
    }
}


//MARK: - Extension 發送簡訊Delegate
extension ViewController: MFMessageComposeViewControllerDelegate {
    //完成後通知
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //關閉簡訊controller
        controller.dismiss(animated: true, completion: nil)
        
        //檢查簡訊發送狀況
        switch result.rawValue{
            
        case MessageComposeResult.sent.rawValue:
            
            print("簡訊已成功送出")
            BackMainPageAlert(title:"簡訊已成功送出")
            break
            
        case MessageComposeResult.cancelled.rawValue:
            
            print("簡訊已被取消")
            BackMainPageAlert(title:"簡訊已被取消")
            break
            
        case MessageComposeResult.failed.rawValue:
            
            print("簡訊因不明原因送出失敗")
            BackMainPageAlert(title:"簡訊因不明原因送出失敗")
            break
            
        default:
            
            print("發生不明錯誤")
            BackMainPageAlert(title:"發生不明錯誤")
            break
        }
    }
    //回到主畫面的alert
    func BackMainPageAlert(title:String){
        
        let myAlert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "關閉", style:.cancel) { alertAction in
            self.captureSession.startRunning()
            self.QRcodeScanView?.frame = CGRect.zero
            self.numberOfPeople = self.peoples[0]
            self.numberOfPeopleButton?.setTitle("\(self.numberOfPeople)", for: .normal)
        }
        myAlert.addAction(cancelAction)
        present(myAlert, animated: true, completion: nil)
    }
}

//MARK: - Extension 相機輸出Delegate
extension ViewController: AVCaptureMetadataOutputObjectsDelegate{
    
    //掃到QRCode時觸發
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        //檢查metadataObjects陣列不為空
        if metadataObjects.count == 0 {
            QRcodeScanView?.frame = CGRect.zero
            return
        }

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        //檢查是否掃到的是QRCode
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            
            //掃到的QRCode
            let barCodeObj = videoPreviewLayer.transformedMetadataObject(for: metadataObj)
            
            //將掃碼框的大小變成跟QRCode的大小一樣
            QRcodeScanView?.frame = barCodeObj!.bounds
            
            if metadataObj.stringValue != nil{
                                
                //實聯制ORCode獲取的資料
                let realNameInformation:String = metadataObj.stringValue!
                
                //掃描到問題時的錯誤彈出式視窗
                let errorAlert = UIAlertController(title: "QRCode格式錯誤", message: "message", preferredStyle: .alert)
                let cancelButton = UIAlertAction(title: "確定", style: .cancel) { alertAction in
                    self.QRcodeScanView?.frame = CGRect.zero
                    self.captureSession.startRunning()
                }
                errorAlert.addAction(cancelButton)
            
                
                
                //1.檢查是否為傳送給1922的QRCode
                guard
                    realNameInformation.range(of: "SMSTO:1922:") != nil
                else {
                    captureSession.stopRunning()
                    errorAlert.message = "掃到的QRCode內容為：\n『\(realNameInformation)』。\n此『QRCode』並非傳送給1922。"
                    present(errorAlert, animated: true, completion: nil)
                    return
                }
                
                //2.檢查是否有場所代碼
                guard
                    realNameInformation.range(of: "場所代碼") != nil
                else{
                    captureSession.stopRunning()
                    errorAlert.message = "掃到的QRCode內容為：\n『\(realNameInformation)』。\n此『QRCode』不包含場所代碼。"
                    present(errorAlert, animated: true, completion: nil)
                    return
                }

                captureSession.stopRunning()
                print("\(realNameInformation)")
                
                //跳到訊息視窗
                sendSMS(Message: realNameInformation)
        
            }
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //組件數
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //滾輪數
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return peoples.count
    }
    //滾輪內容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(peoples[row])
    }
    
    //選擇時觸發
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numberOfPeople = peoples[row]
        numberOfPeopleButton?.setTitle("\(numberOfPeople)", for: .normal)
        pickerView.isHidden = true
    }
}

