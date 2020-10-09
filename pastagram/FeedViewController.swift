//
//  FeedViewController.swift
//  pastagram
//
//  Created by Mireya Leon on 10/6/20.
//  Copyright © 2020 mireyaleon76. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    var numOfPosts: Int!
    let refreshControl = UIRefreshControl()
    
    let headerIdentifier = "TableViewHeaderView"
    //let cellIdentifier = "PostCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // bind the action to the refresh control
        refreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 190
        // insert refresh control into list
        tableView.insertSubview(refreshControl, at: 0)
        
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerIdentifier)

        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadPosts()
        /*numOfPosts = 5
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = numOfPosts
        query.addDescendingOrder("createdAt")
        
        query.findObjectsInBackground{ (posts, error) in
            if posts != nil {
                for post in posts!{
                    if !(self.posts.contains(post)) {
                        self.posts.append(post)
                    }
                }
                //self.posts = posts!
                print(posts?.count)

                self.tableView.reloadData()
            }
        }*/
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(posts.count)
        return posts.count
    }
    
    
   

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as! String
        
        let date = post.createdAt!
        let format = DateFormatter()
        format.dateFormat = "MMM d, h:mma"
        let formattedDate = format.string(from: date)
        print(formattedDate)
        
        print()
        cell.timeStampLabel.text = formattedDate
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.photoView.af.setImage(withURL: url)
        
        
        return cell
        
    }
    
    /*func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let post = posts[section]
        let user = post["author"] as! PFUser
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier)!
        header.textLabel?.text = user.username
        print(user.username)
        return header
    }*/

    /*func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }*/
    
    
    
    @objc func loadPosts() {
        // Call the delay method in your onRefresh() method
        /*func refresh() {
            run(after: 2) {
               self.refreshControl.endRefreshing()
            }
        }*/
        //self.posts.removeAll()
        // call everytime the refresh control is triggered to update table
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.includeKey("createdAt")
        numOfPosts = 20
        query.limit = numOfPosts
    
       
       query.addDescendingOrder("createdAt")

        
        query.findObjectsInBackground{ (posts, error) in
            if posts != nil {
                self.posts.removeAll()
                for post in posts!{
                   if !self.posts.contains(post) {
                        self.posts.append(post)
                    }
                }
                //self.posts = posts!
                //print(posts?.count ?? "")
                // update table with new data
                self.tableView.reloadData()
                // stop animating once new data loaded
                self.refreshControl.endRefreshing()
            } else {
                print("\(String(describing: error?.localizedDescription))")
            }
        }
        
    }
    
    // Implement the delay method
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    func loadMorePosts() {
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.includeKey("createdAt")
        numOfPosts = numOfPosts + 20
        query.limit = numOfPosts
        query.addDescendingOrder("createdAt")

             
        query.findObjectsInBackground{ (posts, error) in
            if posts != nil {
                self.posts.removeAll()
                for post in posts!{
                    if !(self.posts.contains(post)) {
                        self.posts.append(post)
                    }
                }
                   
                // update table with new data
                self.tableView.reloadData()
            } else {
                print("\(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           if indexPath.row + 1 == posts.count {
               loadMorePosts()
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
