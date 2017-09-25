//
//  ProfileController.swift
//  pickup-in-three
//
//  Created by Emily on 7/3/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref: FIRDatabaseReference!
    var imagePicker: UIImagePickerController!
    
    // profile info
    @IBOutlet var name: UILabel!
    @IBOutlet var score: UILabel!
    @IBOutlet var aboutMe: UITextView!
    @IBOutlet var imageView: UIImageView!
    @IBAction func editImage(_ sender: Any) {
        let imagePicker = UIImagePickerController();
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
        imagePicker.allowsEditing = true;
        self.present(imagePicker, animated: true, completion: nil);
    }
    
    // table views
    @IBOutlet var favoriteTable: UITableView!
    @IBOutlet var pickUpTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference();
        // Do any additional setup after loading the view, typically from a nib.
        
        // set name
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            self.name.text = snapshot.value as! String
        });
        
        // set score
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("points").observeSingleEvent(of: .value, with: { (snapshot) in
            self.score.text = String(snapshot.value as! Int)
        });
        
        // set user description
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("aboutMe").observeSingleEvent(of: .value, with: { (snapshot) in
            self.aboutMe.text = snapshot.value! as? String;
        });
        
        // check if profile picture exists, if not set to the thing
    self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("base64string").observeSingleEvent(of: .value, with: { (snapshot) in
            if let same:String = (snapshot.value! as? String) {
                if (same == "default") {
                    self.imageView.image = #imageLiteral(resourceName: "guy");
                }
                else {
                    let dataDecoded:Data = Data(base64Encoded: same, options: .ignoreUnknownCharacters)!
                    let image = UIImage(data: dataDecoded)!
                    self.imageView.image = image;
                }
            }
        });
    }
    
    private func base64PaddingWithEqual(encoded64: String) -> String {
        let remainder = encoded64.characters.count % 4
        if remainder == 0 {
            return encoded64;
        } else {
            // padding with equal
            let newLength = encoded64.characters.count + (4 - remainder);
            return encoded64.padding(toLength: newLength, withPad: "=", startingAt: 0);
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage;
        imageView.image = chosenImage;
        let imageData: Data! = UIImageJPEGRepresentation(chosenImage, 0.1)
        
        let base64String = (imageData as NSData).base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0));
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("base64string").setValue(base64String);
        dismiss(animated: true, completion: nil);
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil);
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismiss(animated: true, completion: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class FavoriteLinesCell: UITableViewCell {
}

class UsersLinesCell: UITableViewCell {
}
