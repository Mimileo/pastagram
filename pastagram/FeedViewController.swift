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
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    // create instance of MessageInputBar
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    var posts = [PFObject]()
    var selectedPost: PFObject! // ! bc optional in case of nil
    
    var numOfPosts: Int!
    let refreshControl = UIRefreshControl()
    
    let headerIdentifier = "TableViewHeaderView"
    //let cellIdentifier = "PostCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tabBarController.navigationItem.rightBarButtonItem = feed_button;
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
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
        
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keybooardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    @objc func keybooardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
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
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut() // clear the cache
    
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let delegate = windowScene.delegate as? SceneDelegate
        else {
          return
        }
        
       // let delegate = UIApplication.shared.delegate as! AppDelegate
        
        delegate.window?.rootViewController = loginViewController
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        // if last cell
       if indexPath.row == comments.count + 1{ // extra cell
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder() // raise the keyboard
        
            // remember this post
            selectedPost = post
        }
        
      
    }
  
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // create comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
                
        selectedPost.add(comment, forKey: "comments")
                
        selectedPost.saveInBackground{ (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
                    
        }
        
        // reload data to update view
        tableView.reloadData()
        
        // clear and dismiss input bar
        commentBar.inputTextView.text = nil
        
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
       // return comments.count + 1 // the # of comments you have + 1 for that post
        return comments.count + 2   // add 2 know bc want placeholder comment cell added
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []

        if indexPath.row == 0 { // it's a post
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            if user["profile_image"] != nil {
                let imageFile = user["profile_image"] as! PFFileObject
                           
                let urlString = imageFile.url!
                let url = URL(string: urlString)!
                //cell.commentImage.af.setImage(withURL: url)
                let placeholderImage = UIImage(named: "profile_placeholder")!
                let placeholder = placeholderImage.af.imageRoundedIntoCircle()

                cell.userImage.af.setImage(withURL: url, placeholderImage: placeholder)
            } else {
                cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width / 2
                cell.userImage.clipsToBounds = true
            }
            
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
        } else if indexPath.row  <= comments.count { // within comments so it's a comment
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            
            if comment["text"] != nil {
                cell.commentLabel.text = comment["text"] as! String
            }
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            if user["profile_image"] != nil {
                let imageFile = user["profile_image"] as! PFFileObject
                
                let urlString = imageFile.url!
                let url = URL(string: urlString)!
                //cell.commentImage.af.setImage(withURL: url)
                let placeholderImage = UIImage(named: "profile_placeholder")!
                let placeholder = placeholderImage.af.imageRoundedIntoCircle()

                cell.commentImage.af.setImage(withURL: url, placeholderImage: placeholder)
            } else {
                 cell.commentImage.layer.cornerRadius = cell.commentImage.frame.size.width / 2
                 cell.commentImage.clipsToBounds = true
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
        
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
        query.includeKeys(["author", "comments", "comments.author"])
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
        query.includeKeys(["author", "comments", "comments.author"])
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
