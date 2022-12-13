//
//  HomeTableViewController.swift
//  VideoFinder
//
//  Created by yuri on 2022/10/26.
//

import UIKit



class HomeTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnPrev: UIBarButtonItem!
    @IBOutlet weak var btnNext: UIBarButtonItem!
    
    let fileName = "LikeList"
    var likeList:NSMutableArray?
    
    
    
    let host = "https://dapi.kakao.com/v2/search/vclip"
    
    var page = 1
    var defaultText = UserDefaults.standard.string(forKey: "defaultText") != nil ? UserDefaults.standard.string(forKey: "defaultText") : "아이유"

    let pageSize = 10
    
    var videoList: [Vclip] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 130
        searchBar.delegate = self
        searchBar.text = defaultText
        
        let targetPath = getFilePath(fileName: fileName+".plist")
        //path는 무조건 optional
        guard let originPath = Bundle.main.path(forResource: fileName, ofType: "plist") else {return}
        copyFile(originPath,targetPath)
        
        guard let likeList = NSMutableArray(contentsOfFile: targetPath) else {return}
        self.likeList = likeList
        print("홈 ", self.likeList)
        
        search(defaultText, page)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let targetPath = getFilePath(fileName: fileName+".plist")
        //path는 무조건 optional
        guard let originPath = Bundle.main.path(forResource: fileName, ofType: "plist") else {return}
        copyFile(originPath,targetPath)
        
        guard let likeList = NSMutableArray(contentsOfFile: targetPath) else {return}
        self.likeList = likeList
        print("홈 reload", self.likeList)
        
//        print("aaa", UserDefaults.standard.string(forKey: "defaultText"))
        defaultText = UserDefaults.standard.string(forKey: "defaultText") != nil ? UserDefaults.standard.string(forKey: "defaultText") : "아이유"
        searchBar.text = defaultText
        search(defaultText, page)
    }
    
    @IBAction func actPrev(_ sender: Any) {
        page -= 1
        search(defaultText, page)
    }
    
    @IBAction func actNext(_ sender: Any) {
        page += 1
        search(defaultText, page)
    }
    
    
    func search(_ query: String?, _ page: Int){
        guard let query = query else {return}
        let str = host + "?size=\(pageSize)&query=\(query)&page=\(page)" //sort
        if let strUrl = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: strUrl){
            var request = URLRequest(url: url)
            request.addValue(apiKey, forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, response, error in
                //                if let error = error{
                //                    print("error:",error.localizedDescription)
                //                    return
                //                }
                guard let data = data else {return}
                do{
                    let result = try JSONDecoder().decode(ResultData.self, from: data)
                    self.videoList = result.documents
                    DispatchQueue.main.async {
                        self.tableView.reloadData() //mainQueue에서 작업해야됨!!
                        self.btnNext.isEnabled = !result.meta.is_end
                    }
                    
                }catch{
                    print("패싱 실패") //struct 타입 맞는지 확인해보기!!
                }
            }.resume() //실행
            
        }
        btnPrev.isEnabled = page > 1
        
    }
    
    
    @IBAction func actLike(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at:buttonPosition){
            
            guard let likeList = self.likeList else {fatalError()}
            let videoInfo = videoList[indexPath.row] //selected
            
            let newDic = [
                "title" : videoInfo.title,
                "url" : videoInfo.url,
                "datetime" : videoInfo.datetime,
                "play_time" : videoInfo.play_time,
                "thumbnail" : videoInfo.thumbnail,
                "author" : videoInfo.author
            ] as [String : Any]
            
            if likeList.count > 0 {
                var overlap = false
                var overlapIndex = 0
                for (i, ele) in likeList.enumerated(){
                    
                    if let ele = ele as? [String:Any]  {
                        if ele["url"] as! String == videoInfo.url {
                            print("이미 있다! : ",i)
                            print("이미 있다! : ",ele["url"] ,":",videoInfo.url )
                            overlap = true
                            overlapIndex = i
                            break
                        }
                    }
                }//for end
                if overlap {
                    likeList.removeObject(at: overlapIndex)
                    let filePath = getFilePath(fileName: fileName+".plist")
                    let result =  likeList.write(toFile: filePath, atomically: true)
                    if result {
                        sender.setImage(UIImage(systemName: "heart"), for: .normal)
                        let alert =  makeAlertWithOneAction(title: nil, message: "삭제되었습니다.")
                        present(alert, animated: true)
                    }else{
                        let alert = makeAlertWithOneAction(title: nil, message: "삭제 실패했습니다.")
                        present(alert, animated: true)
                    }
                }else{
                    likeList.add(newDic)
                    let filePath = getFilePath(fileName: fileName+".plist")
                    let result =  likeList.write(toFile: filePath, atomically: true)
                    if result {
                        sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                        let alert = makeAlertWithOneAction(title: nil, message: "추가되었습니다.")
                        present(alert, animated: true)
                    }else{
                        let alert = makeAlertWithOneAction(title: nil, message: "추가 실패했습니다.")
                        present(alert, animated: true)
                    }
                }
                
            }else{
                print("없으니까 바로 실행!! ")
                
                likeList.add(newDic)
                let filePath = getFilePath(fileName: fileName+".plist")
                let result =  likeList.write(toFile: filePath, atomically: true)
                if result {
                    sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    let alert = makeAlertWithOneAction(title: nil, message: "추가되었습니다.")
                    present(alert, animated: true)
                }else{
                    let alert = makeAlertWithOneAction(title: nil, message: "추가 실패했습니다.")
                    present(alert, animated: true)
                }
            }
            
        }//indexPath end
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return videoList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videocell", for: indexPath)
        
        let videoInfo = videoList[indexPath.row]
        
        let videoImage = cell.viewWithTag(1) as? UIImageView
        let imgUrl = videoInfo.thumbnail
        
        guard let url = URL(string: imgUrl) else { fatalError() }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, URLResponse, error in
            if let imageData = data {
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    videoImage?.image = image
                }
            }else{
                print("사진 불러오기 실패")
            }
        }.resume()
        
        let videoTime = cell.viewWithTag(2) as? UILabel
        videoTime?.text = secondsToHoursMinutesSeconds(seconds: Int(videoInfo.play_time))
        //        videoImage?.addSubview(videoTime!)
        
        let videoTitle = cell.viewWithTag(3) as? UILabel
        videoTitle?.text = videoInfo.title
        
        
        let videoDate = cell.viewWithTag(4) as? UILabel
        videoDate?.text = subString(str:videoInfo.datetime, start: 0, end: 10)
        
        
        let videoAuthor = cell.viewWithTag(5) as? UILabel
        videoAuthor?.text = videoInfo.author
        
        
        let likeBtn = cell.viewWithTag(6) as? UIButton
        guard let likeList = self.likeList else {fatalError()}
        for (i, ele) in likeList.enumerated(){
            if let ele = ele as? [String:Any]  {
                if ele["url"] as! String == videoInfo.url {
                    //print("테이블에 있다! : ",i,":",ele["url"] ,":",videoInfo.url )
                    //print(videoInfo.title)
                    likeBtn?.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    break
                }else{
                    //print("테이블에  없다! : ",i,":",ele["url"] ,":",videoInfo.url )
                    //print(videoInfo.title)
                    likeBtn?.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            }
        }
        
        return cell
    }
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let index = tableView.indexPathForSelectedRow else {return}
        let dvc = segue.destination as? DetailViewController
        dvc?.site = videoList[index.row].url
    }
    
    
}

extension HomeTableViewController: UISearchBarDelegate {
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" || searchBar.text == nil {
            let alert = UIAlertController(title: "", message: "검색어를 입력해주세요", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
        }else{
            page = 1
            defaultText = searchBar.text!
            search(defaultText, page)
            searchBar.resignFirstResponder() //키보드내림
        }
    }
}



