//
//  LikeTableViewController.swift
//  VideoFinder
//
//  Created by yuri on 2022/10/26.
//

import UIKit


class LikeTableViewController: UITableViewController {
    @IBOutlet weak var btnPrev: UIBarButtonItem!
    @IBOutlet weak var btnNext: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let fileName = "LikeList"
    var likeList:NSMutableArray? //원본
    var searchList:[[String:Any]] = [] //검색내용
    var searchPageList:[[String:Any]] = [] //페이징처리한 리스트
    var filtered:[[String:Any]] = []
    
    var page = 1
    var defaultText = ""
    let pageSize = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 130
        searchBar.delegate = self
//        let aa = [1,2,3,4,5,6,7,8,9,10,11,12,13]
//        print("aa", aa[0...9]) //1~10
        
        
        let targetPath = getFilePath(fileName: fileName+".plist")
        //path는 무조건 optional
        guard let originPath = Bundle.main.path(forResource: fileName, ofType: "plist") else {return}
        copyFile(originPath,targetPath)
        
        guard let likeList = NSMutableArray(contentsOfFile: targetPath) else {return}
        self.likeList = likeList
        searchList = likeList as! [[String : Any]]
        print("좋아요 초반 ", self.likeList)
        print("좋아요 초반 searchList ", searchList)
        search(defaultText, page)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    override func viewWillAppear(_ animated: Bool) {
        let targetPath = getFilePath(fileName: fileName+".plist")
        //path는 무조건 optional
        guard let originPath = Bundle.main.path(forResource: fileName, ofType: "plist") else {return}
        copyFile(originPath,targetPath)
        
        guard let likeList = NSMutableArray(contentsOfFile: targetPath) else {return}
        self.likeList = likeList
        searchList = likeList as! [[String : Any]]
        print("좋아요 리로드 ", self.likeList)
        print("좋아요 리로드 searchList ", searchList)
        search(defaultText, page)
    }
    func search(_ query: String?, _ page: Int){
//        if query == "" { return } //초기에 빈 검색어일 때
        guard let query = query else {return}
        guard let tmpList = self.likeList else {fatalError()}
    
        if let tmpList = tmpList as? [[String: Any]] {
            if query != "" {
//                print("빈 검색어")
//                searchList = tmpList
//            }else{
                print("query",query)
                searchList = tmpList.filter {
                    ($0["title"] as? String)?
                        .range(of: query, options: [.caseInsensitive]) != nil
                    ||
                    ($0["author"] as? String)?
                        .range(of: query, options: [.caseInsensitive]) != nil
                }
            }
       
//            searchList = filtered

           
            let lastIndex = searchList.count - 1
            let startIndex = (page-1) * pageSize
            let endIndex = (page*pageSize) - 1
            
            print("lastIndex",lastIndex)
            print("startIndex",startIndex)
            print("endIndex",endIndex)
            if endIndex < lastIndex{
                searchPageList = Array(searchList[startIndex...endIndex])
            }else{
                searchPageList = Array(searchList[startIndex...lastIndex])
            }
            print("searchPageList",searchPageList)
//            likeList?.setArray(filtered)
            
            DispatchQueue.main.async {
                self.tableView.reloadData() //mainQueue에서 작업해야됨!!
                self.btnNext.isEnabled = lastIndex > endIndex

                
            }
        }

        btnPrev.isEnabled = page > 1
    }
    
    @IBAction func actPrev(_ sender: Any) {
        page -= 1
        search(defaultText, page)
    }
    
    @IBAction func actNext(_ sender: Any) {
        page += 1
        search(defaultText, page)
    }
    
    @IBAction func actRemove(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at:buttonPosition){
            guard let likeList = self.likeList else {fatalError()}
            let selectInfo = searchPageList[indexPath.row] //selected
            print("selectInfo",selectInfo)
            var removeIndex = 0
            for (i, ele) in likeList.enumerated(){
                if let ele = ele as? [String:Any]  {
                    if ele["url"] as! String == selectInfo["url"] as! String  {
                        print("삭제할 인덱스! : ",i)
                        removeIndex = i
                        break
                    }
                }
            }//for end
            
            likeList.removeObject(at: removeIndex)
            let filePath = getFilePath(fileName: fileName+".plist")
            let result =  likeList.write(toFile: filePath, atomically: true)
            if result {
                print("searchPageList index",indexPath.row)
                searchPageList.remove(at: indexPath.row)
                print("cnt", searchPageList.count)

                
                let alert = UIAlertController(title: nil, message: "삭제 되었습니다.", preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default) { (action) in
                    DispatchQueue.main.async {
                        print("reload")
                        self.tableView.reloadData() //mainQueue에서 작업해야됨!!
                    }
                }
                alert.addAction(action)
                present(alert, animated:true)
            }else{
                let alert = makeAlertWithOneAction(title: nil, message: "삭제 실패했습니다.")
                present(alert, animated: true)
            }
            
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        if let cnt = likeList?.count {
//            return cnt
//        }else{
//            return 0
//        }
       return searchPageList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videocell", for: indexPath)

//        guard let likeList = self.likeList , let videoInfo = likeList[indexPath.row] as? [String:Any] else { fatalError() }
        
        let videoInfo = searchPageList[indexPath.row]


        let videoImage = cell.viewWithTag(1) as? UIImageView
        guard let imgUrl = videoInfo["thumbnail"] as? String, let url = URL(string: imgUrl) else { fatalError() }
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
        if let time = videoInfo["play_time"] as? Int{
            videoTime?.text = secondsToHoursMinutesSeconds(seconds: Int(time))
        }

        let videoTitle = cell.viewWithTag(3) as? UILabel
        videoTitle?.text = videoInfo["title"] as? String

        let videoDate = cell.viewWithTag(4) as? UILabel
        if let date = videoInfo["datetime"] as? String {
            videoDate?.text = subString(str:date, start: 0, end: 10)
        }
    
        let videoAuthor = cell.viewWithTag(5) as? UILabel
        videoAuthor?.text = videoInfo["author"] as? String
        
        let likeBtn = cell.viewWithTag(6) as? UIButton
        likeBtn?.setImage(UIImage(systemName: "heart.fill"), for: .normal)

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
        dvc?.site = searchList[index.row]["url"] as! String
    }
    

}

extension LikeTableViewController:UISearchBarDelegate {
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            page = 1
            defaultText = searchBar.text!
            search(defaultText, page)
            searchBar.resignFirstResponder() //키보드내림
    }
}
