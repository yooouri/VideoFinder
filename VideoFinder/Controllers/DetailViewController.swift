//
//  DetailViewController.swift
//  VideoFinder
//
//  Created by yuri on 2022/10/26.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView! //홈
    @IBOutlet weak var webView2: WKWebView! //좋아요
 
    var site:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: site) else {return}
        let request = URLRequest(url: url)
        
        let viewControllers = self.navigationController?.viewControllers
        let count = viewControllers?.count
        guard let count = viewControllers?.count else {return}
//        print("count",count)
//        print("viewControllers",viewControllers)
        
        if count > 1 {
            if let setVC = viewControllers?[count - 2] as? UITableViewController {
                if setVC is HomeTableViewController{
                    //홈
                    webView.load(request)
                }else{
                    //좋아요
                    webView2.load(request)
                }
                
            }
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

