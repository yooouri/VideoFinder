//
//  MyUpdateViewController.swift
//  VideoFinder
//
//  Created by yuri on 2022/10/26.
//

import UIKit
import PhotosUI

class MyUpdateViewController: UIViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var textNick: UITextField!
    @IBOutlet weak var textMotto: UITextField!
    @IBOutlet weak var textDefaultText: UITextField!
    
    let cameraPicker = UIImagePickerController() //카메라
    var galleryPicker: PHPickerViewController? //갤러리 (UIImagePickerController의 photolibrary가 diprecated라서 phpicker사용함)
    
    //    let fileName = "UserData"
    //    var userData:NSMutableDictionary?
    let nick = UserDefaults.standard.string(forKey: "userNick")
    let motto = UserDefaults.standard.string(forKey: "userMotto")
    let defaultText = UserDefaults.standard.string(forKey: "defaultText")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraPicker.delegate = self
        
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        galleryPicker = PHPickerViewController(configuration: config)
        galleryPicker?.delegate = self
        
        //plist 사용
        //        let targetPath = getFilePath(fileName: fileName+".plist")
        //        //path는 무조건 optional
        //        guard let originPath = Bundle.main.path(forResource: fileName, ofType: "plist") else {return}
        //        copyFile(originPath,targetPath)
        //
        //        guard let userData = NSMutableDictionary(contentsOfFile: targetPath) else {return}
        //        self.userData = userData
        //        print("초반 ", self.userData)
        
        //빌드할때 마다 경로 바뀌기 때문에,, 새로 읽어옴
        let fileUrl = docUrlFileName("userProfile.png")
        let image = UIImage(contentsOfFile: fileUrl.path())
        if image != nil {
            imgProfile.image = image
        }
        print("image",image)
        
        if nick != nil {
            textNick.text = nick
        }else{
            textNick.placeholder = "닉네임을 입력해주세요"
        }
        if motto != nil {
            textMotto.text = motto
        }else{
            textMotto.placeholder = "좌우명을 입력해주세요"
        }
        if defaultText != nil {
            textDefaultText.text = defaultText
        }else{
            textDefaultText.placeholder = "기본검색어를 입력해주세요"
        }
    }
    
    @IBAction func actCamera(_ sender: Any) {
        self.cameraPicker.sourceType = .camera
        self.present(self.cameraPicker, animated: true)
    }
    
    @IBAction func actGallery(_ sender: Any) {
        guard let galleryPicker = self.galleryPicker else {return}
        self.present(galleryPicker, animated: true)
    }
    
    
    @IBAction func actSave(_ sender: Any) {
        if imgProfile.image != nil && imgProfile.image?.isSymbolImage == false {
            let fileUrl = docUrlFileName("userProfile.png")
            
            do{
                try saveImageWithUrl(fileUrl, image: imgProfile.image, quality: 0.8)
            }catch{
                let alert = UIAlertController(title: "이미지 저장 실패", message: "다시 시도해주세요", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default) { (action) in
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(action)
                present(alert, animated:true)
            }
        }
        
        //plist 사용
        //guard let userData = self.userData else {return}
        //userData?["userImage"] = "userProfile.png"
        //userData?["userNick"] = textNick.text
        //userData?["userMotto"] = textMotto.text
        //userData?["defaultText"] = textDefaultText.text
        //userData?.write(toFile: getFilePath(fileName: fileName+".plist"), atomically: true)
        
        //UserDefaults 저장
        if textNick.text != nil && textNick.text != "" {
            UserDefaults.standard.set(textNick.text, forKey: "userNick")
        }
        
        if textMotto.text != nil && textMotto.text != "" {
            UserDefaults.standard.set(textMotto.text, forKey: "userMotto")
        }
        
        if textDefaultText.text != nil && textDefaultText.text != "" {
            UserDefaults.standard.set(textDefaultText.text, forKey: "defaultText")
        }

        //UserDefaults(싱글톤,환경설정 dic) 가져오기
        //UserDefaults.standard.string(forKey: <#T##String#>)

        if (imgProfile.image != nil && imgProfile.image?.isSymbolImage == false) ||
            (textNick.text != nil && textNick.text != "") ||
            (textMotto.text != nil && textMotto.text != "") ||
            (textDefaultText.text != nil && textDefaultText.text != "") {
            let alert = UIAlertController(title: nil, message: "저장되었습니다", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(action)
            present(alert, animated:true)
        }else{
            let alert = makeAlertWithOneAction(title: nil, message: "저장할 내용이 없습니다")
            present(alert, animated:true)
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


extension MyUpdateViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        if let itemProvider = results.first?.itemProvider {
            if itemProvider.canLoadObject(ofClass: UIImage.self){
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let img = image as? UIImage {
                        //DispatchQueue 설정 안 해주면 터짐,,
                        DispatchQueue.main.async {
                            self.imgProfile.image = img
                        }
                    }
                }
            }
        }
    }
    
    
}

extension MyUpdateViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {return}
        self.imgProfile.image = image
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}
