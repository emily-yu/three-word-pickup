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
    var postedLinesKey: [String] = [];
    var favoritesLines: [String] = [];
    var favoritesLinesKey: [String] = [];
    var requests: [String] = [];
    var requestsKey: [String] = [];
    var tableData: [String] = [];
    
    @IBOutlet var static_selector: UISegmentedControl!
    
    @IBAction func logout(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        UserDefaults.standard.set("", forKey: userDetails.username);
        UserDefaults.standard.set("", forKey: userDetails.password);
        appFunctions().fadeTransition(identifier: "Login");
    }
    @IBAction func tableChanged(_ sender: Any) {
        if (static_selector.selectedSegmentIndex == 0) {
            // favorites
            progressBar.setProgress(0.333333333, animated: false);
            tableData = favoritesLines;
            self.tableView.reloadData();
        }
        else if (static_selector.selectedSegmentIndex == 1) {
            // pickup lines
            self.progressBar.setProgress(0.66666666, animated: false);
            tableData = postedLines;
            profileTable_isFirstLoad = false;
            self.tableView.reloadData();
        }
        else {
            // requests
            self.progressBar.setProgress(1, animated: false);
            tableData = requests;
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
        let currentUserRef = self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid);
        currentUserRef.child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            self.name.text = snapshot.value as! String;
        });
        
        // set score
        currentUserRef.child("points").observeSingleEvent(of: .value, with: { (snapshot) in
            self.score.text = String(snapshot.value as! Int);
        });
        
        // set user description
        currentUserRef.child("aboutMe").observeSingleEvent(of: .value, with: { (snapshot) in
            self.aboutMe.text = snapshot.value! as? String;
        });
        
        // check if profile picture exists, if not set to the thing
        currentUserRef.child("base64string").observeSingleEvent(of: .value, with: { (snapshot) in
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
        postedLinesKey.removeAll();
        currentUserRef.child("lines").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for line in snapshot.children.allObjects as! [FIRDataSnapshot] {
                if (line.key != "0") {
                    self.postedLines.append(line.value as! String);
                    self.postedLinesKey.append(line.key);
                }
            }
        }
        favoritesLines.removeAll();
        favoritesLinesKey.removeAll();
        currentUserRef.child("favorites").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for line in snapshot.children.allObjects as! [FIRDataSnapshot] {
                if (line.key != "0") {
                    self.favoritesLines.append(line.value as! String);
                    self.favoritesLinesKey.append(line.key);
                }
            }
        }
        requests.removeAll();
        requestsKey.removeAll();
        currentUserRef.child("requests").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for line in snapshot.children.allObjects as! [FIRDataSnapshot] {
                if (line.key != "0") {
                    self.requests.append(line.value as! String);
                    self.requestsKey.append(line.key);
                    self.tableData = self.favoritesLines;
                    self.tableView.reloadData();
                }
            }
        }
        
    }
    
    private func base64PaddingWithEqual(encoded64: String) -> String {
        let remainder = encoded64.characters.count % 4;
        if remainder == 0 {
            return encoded64;
        }
        else {
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
        dismiss(animated: true, completion: nil);
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismiss(animated: true, completion: nil);
    }
    
    // tableView
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count;
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ProfileViewCell") as! ProfileViewCell;
        cell.cellText.text = String(tableData[indexPath.row]);
        
        return cell;
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(favoritesLines)
        print(postedLines)
        print(requests)
        tableView.deselectRow(at: indexPath, animated: true);
        
        // favorites
        if (static_selector.selectedSegmentIndex == 0) {
            let alertController = UIAlertController(title: "Confirm", message: "You are about to remove this line from your favorites.", preferredStyle: .alert);
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
            alertController.addAction(cancelAction);
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("favorites").child(self.favoritesLinesKey[indexPath.row]).removeValue { (error, ref) in
                    if error != nil {
                        print("error \(error)")
                    }
                }
                self.favoritesLines.remove(at: indexPath.row);
                self.favoritesLinesKey.remove(at: indexPath.row);
                self.tableData = self.favoritesLines;
                self.tableView.reloadData();
            });
            alertController.addAction(defaultAction);
            
            self.present(alertController, animated: true, completion: nil);
        }
            
        // pickup lines
        else if (static_selector.selectedSegmentIndex == 1) {
            let alertController = UIAlertController(title: "Confirm", message: "You are about to delete this line from the global community.", preferredStyle: .alert);
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
            alertController.addAction(cancelAction);
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
            
                // TODO: go through each user's details and delete it if they favorited it
                // delete every instance of that line
                self.ref.child("users").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                    print("YA")
                    print(snapshot.value)
                    print(self.favoritesLines[indexPath.row])
                    for line in snapshot.children.allObjects as! [FIRDataSnapshot] {
                        let restDict = line.value as? [String: Any];
                        let KeyDict = line.key as? [String: Any];
//                        let userRef = self.ref.child["text"] as? String;
                        if (line.key != "0") {
//                            self.postedLines.append(line.value as! String);
//                            self.postedLinesKey.append(line.key);
                            print("USER")
                            print(line) // user
                            print(restDict!["favorites"])
                            print("FAVORITES:")
                            let favoriteDict = restDict!["favorites"] as? [String]
                            print(favoriteDict)
//                            print("KEYS:")
//                            print(restDict!["favorites"])
//                            print(type(of: restDict!["favorites"]))
//                            print("SAME")
                            
                            
                            // TODO: TEST WITH MULTIPLE USERS
                            for favorite in favoriteDict! {
                                if (favorite == self.postedLines[indexPath.row]) { // same line
                                    print(favorite) // line being scanned for
                                    print(line.key) // user to delete from
                                    if (line.key == FIRAuth.auth()!.currentUser!.uid) {
                                        // remove from postedLines.child(postedLines[indexPaht.row])
                                        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("lines").child(self.postedLinesKey[indexPath.row]).removeValue { (error, ref) in
                                            if error != nil {
                                                print("error \(error)")
                                            }
                                        }
                                    }
                                    else {
                                        // remove from favorites.child()
                                        self.ref.child("users").child(line.key).child("favorites").observeSingleEvent(of: .value, with: { (snapshot) in
                                            var myArrayKey = [String]()
                                            var myArray = [String]()
                                            for child in snapshot.children {
                                                myArrayKey.append((child as AnyObject).key as String)
                                                myArray.append((child as AnyObject).value)
                                            }
                                            let pos = myArray.index(of: favorite);
                                            print("BLEUGH")
                                            print(myArray)
                                            print("postion = \(pos!)") // index
                                            
                                            self.ref.child("users").child(line.key).child("favorites").child(String(describing: pos!)).removeValue { (error, ref) in
                                                if error != nil {
                                                    print("error \(error)")
                                                }
                                                print("SAME we dun it")
                                            }
                                        });
                                    }
                                    print(self.postedLines[indexPath.row])
                                }
                            }
                        }
                    }
                }
                
                self.postedLines.remove(at: indexPath.row);
                self.postedLinesKey.remove(at: indexPath.row);
                self.tableData = self.postedLines;
                self.tableView.reloadData();
        
            });
            alertController.addAction(defaultAction);
            
            self.present(alertController, animated: true, completion: nil);
        }
            
        // requests
        else {
            let alertController = UIAlertController(title: "Confirm", message: "You are about to remove this request from the global community.", preferredStyle: .alert);
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
            alertController.addAction(cancelAction);
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in

                self.ref.child("request").child(self.requestsKey[indexPath.row]).removeValue { (error, ref) in
                    if error != nil {
                        print("error \(error)")
                    }
                }
                
                self.requests.remove(at: indexPath.row);
                self.requestsKey.remove(at: indexPath.row);
                self.tableData = self.requests;
                self.tableView.reloadData();
            });
            alertController.addAction(defaultAction);
            
            self.present(alertController, animated: true, completion: nil);
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class ProfileViewCell: UITableViewCell {
    @IBOutlet var cellText: UILabel!
}
