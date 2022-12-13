//
//  MyViewController.swift
//  VideoFinder
//
//  Created by yuri on 2022/10/26.
//

import UIKit

class MyViewController: UIViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblNick: UILabel!
    @IBOutlet weak var lblMotto: UILabel!
    @IBOutlet weak var lblDefaultText: UILabel!
    
    //    let fileName = "UserData"
    //    var userData:NSDictionary?
    let nick = UserDefaults.standard.string(forKey: "userNick")
    let motto = UserDefaults.standard.string(forKey: "userMotto")
    let defaultText = UserDefaults.standard.string(forKey: "defaultText")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //plist 사용
        //        if let path = Bundle.main.path(forResource: fileName, ofType: "plist") {
        //            guard let userData = NSDictionary(contentsOfFile: path) else { return }
        //
        //            if let nick = userData["userNick"] as? String {
        //                if nick == "" { lblNick.text = "이름을 넣어주세요" }
        //                else{ lblNick.text = nick }
        //            }
        //
        //            if let motto = userData["userMotto"] as? String {
        //                if motto == "" { lblMotto.text = "좌우명을 넣어주세요" }
        //                else{ lblMotto.text = motto }
        //            }
        //
        //            if let defaultText = userData["defaultText"] as? String {
        //                if defaultText == "" { lblDefaultText.text = "기본 검색어를 넣어주세요" }
        //                else{ lblDefaultText.text = defaultText }
        //            }
        //
        //        }//path end
        
        //빌드할때 마다 경로 바뀌기 때문에,, 새로 읽어옴
        let fileUrl = docUrlFileName("userProfile.png")
        let image = UIImage(contentsOfFile: fileUrl.path())
        if image != nil {
            imgProfile.image = image
        }

        if nick != nil {
            lblNick.textColor = .black
            lblNick.text = nick
        }
        if motto != nil {
            lblMotto.textColor = .black
            lblMotto.text = motto
        }
        if defaultText != nil {
            lblDefaultText.textColor = .black
            lblDefaultText.text = defaultText
        }
        
        
    }//viewDidLoad end
    
    
    //수정 후 refresh를 위해
    override func viewWillAppear(_ animated: Bool) {
        let nick = UserDefaults.standard.string(forKey: "userNick")
        let motto = UserDefaults.standard.string(forKey: "userMotto")
        let defaultText = UserDefaults.standard.string(forKey: "defaultText")
        
        let fileUrl = docUrlFileName("userProfile.png")
        let image = UIImage(contentsOfFile: fileUrl.path())
        if image != nil {
            imgProfile.image = image
        }

        if nick != nil {
            lblNick.textColor = .black
            lblNick.text = nick
        }
        if motto != nil {
            lblMotto.textColor = .black
            lblMotto.text = motto
        }
        if defaultText != nil {
            lblDefaultText.textColor = .black
            lblDefaultText.text = defaultText
        }
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//border 추가하기 위해
extension UIView {
    @IBInspectable var borderColor: UIColor {
        get {
            let color = self.layer.borderColor ?? UIColor.clear.cgColor
            return UIColor(cgColor: color)
        }
        
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        
        set {
            self.layer.borderWidth = newValue
        }
    }
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
}


