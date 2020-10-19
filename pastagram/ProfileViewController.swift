//
//  ProfileViewController.swift
//  pastagram
//
//  Created by Mireya Leon on 10/13/20.
//  Copyright © 2020 mireyaleon76. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
                       
        profileImageView.clipsToBounds = true

        if PFUser.current() != nil {
            let user = PFUser.current()!
            
            self.navigationItem.title = user.username
            if user["profile_image"] != nil {
                //profileImageView.image = scaledImage.af.imageRoundedIntoCircle()
                let imageFile = user["profile_image"] as! PFFileObject
                let urlString = imageFile.url!
                let url = URL(string: urlString)!
                profileImageView.af.setImage(withURL: url)
               // let size = CGSize(width: 300, height: 300)
                //let imageView = UIImageView(frame: size)
                //let url = URL(string: "https://httpbin.org/image/png")!
                let placeholderImage = UIImage(named: "profile_placeholder")!
                let placeholder = placeholderImage.af.imageRoundedIntoCircle()

                profileImageView.af.setImage(withURL: url, placeholderImage: placeholder)
            }
            
        }
       
        // Do any additional setup after loading the view.
    }
    
   
    

    @IBAction func onProfileImageTap(_ sender: Any) {
        print("tapped")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
               
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
               
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageAspectScaled(toFill: size)
        
        profileImageView.image = scaledImage.af.imageRoundedIntoCircle()
        
        dismiss(animated: true, completion: nil)
        
         if PFUser.current() != nil {
            print(PFUser.current())
            let user = PFUser.current()!
            
            let post = PFObject(className: "Posts")
          
            let imageData = profileImageView.image!.pngData()
            let file = PFFileObject(name: "profile_image.png", data: imageData!)
                          
            user["profile_image"] = file
            
                          
            user.saveInBackground{ (success, error) in
                       if success {
                           self.dismiss(animated: true, completion: nil)
                           print("saved profile image")
                       } else {
                           print("error")
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
