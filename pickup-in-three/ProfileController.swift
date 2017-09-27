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

class ProfileController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var progressBar: UIProgressView!
    var ref: FIRDatabaseReference!
    var profileTable_isFirstLoad = true;
    var imagePicker: UIImagePickerController!
    var postedLines: [String] = [];
    var favoritesLines: [String] = [];
    var tableData: [String] = [];
    
    @IBOutlet var static_selector: UISegmentedControl!
    
    @IBAction func tableChanged(_ sender: Any) {
        if (static_selector.selectedSegmentIndex == 0) {
            // favorites
            progressBar.setProgress(0.5, animated: false);
            tableData = favoritesLines;
            self.tableView.reloadData();
        }
        else {
            // pickup lines
            self.progressBar.setProgress(1, animated: false);
            tableData = postedLines;
            profileTable_isFirstLoad = false;
            self.tableView.reloadData();
        }
    }
    
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
        
        let cellReuseIdentifier = "cell";
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
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
        
        // retrieve data
        postedLines.removeAll();
        ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("lines").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for line in snapshot.children {
                if ((line as AnyObject).key != "0") {
                self.postedLines.append((line as AnyObject).value);
                }
            }
        }
        favoritesLines.removeAll();
        ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("favorites").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for line in snapshot.children {
                if ((line as AnyObject).key != "0") {
                self.favoritesLines.append((line as AnyObject).value);
                    self.tableData = self.favoritesLines
                    self.tableView.reloadData();
                }
            }
        }
        
//        tableData = favoritesLines;
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
    
    // tableView
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (profileTable_isFirstLoad) {
//            return userGroups.count;
//        }
//        else {
//            return tableData.count;
//        }
        return tableData.count;
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ProfileViewCell") as! ProfileViewCell;
//        if (profileTable_isFirstLoad) {
//            cell.cellText.text = String(tableData[indexPath.row]);
//        }
//        else {
            cell.cellText.text = String(tableData[indexPath.row]);
//        }
        
        return cell;
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(favoritesLines)
        print(postedLines)
//        if (static_selector.selectedSegmentIndex == 0) { // communities
//            let textToFind = String(userGroups[indexPath.row]);
//            groupDetailsTitle = textToFind!
//
//            let ivc = self.storyboard?.instantiateViewController(withIdentifier: "GroupDetailsController");
//            ivc?.modalPresentationStyle = .custom;
//            ivc?.modalTransitionStyle = .crossDissolve;
//            self.present(ivc!, animated: true, completion: { _ in });
//        }
//        else if (static_selector.selectedSegmentIndex == 1) { // favorites - incomplete; hide me too and stuff based on uid
//            let textToFind = String(myPostsText[indexPath.row]);
//            let refPath = self.ref.child("post");
//
//            refPath.queryOrdered(byChild: "text").queryEqual(toValue:textToFind).observe(.value, with: { snapshot in
//                if (snapshot.value is NSNull) {
//                    print("Item was not found");
//                }
//                else {
//                    for child in snapshot.children {
//                        let key = (child as AnyObject).key as String;
//                        clickedIndex = Int(key);
//
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//                        let ivc = storyboard.instantiateViewController(withIdentifier: "postInfo");
//                        ivc.modalPresentationStyle = .custom;
//                        ivc.modalTransitionStyle = .crossDissolve;
//                        self.present(ivc, animated: true, completion: { _ in });
//                    }
//                }
//            });
//            tableView.deselectRow(at: indexPath, animated: true);
//        }
//        else { // posts
//            let textToFind = String(myPostsText[indexPath.row]);
//            let refPath = self.ref.child("post");
//
//            refPath.queryOrdered(byChild: "text").queryEqual(toValue:textToFind).observe(.value, with: { snapshot in
//                if (snapshot.value is NSNull) {
//                    print("Item was not found");
//                }
//                else {
//                    for child in snapshot.children {
//                        let key = (child as AnyObject).key as String;
//                        clickedIndex = Int(key);
//
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//                        let ivc = storyboard.instantiateViewController(withIdentifier: "postInfo");
//                        ivc.modalPresentationStyle = .custom;
//                        ivc.modalTransitionStyle = .crossDissolve;
//                        self.present(ivc, animated: true, completion: { _ in });
//                    }
//                }
//            });
//            tableView.deselectRow(at: indexPath, animated: true);
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class ProfileViewCell: UITableViewCell {
    @IBOutlet var cellText: UILabel!
}
