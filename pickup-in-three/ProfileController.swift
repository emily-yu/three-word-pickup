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

class ProfileController: UIViewController {
    
    var ref:FIRDatabaseReference!
    
    // profile info
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var score: UILabel!
    @IBOutlet var aboutMe: UITextView!
    
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
            self.score.text = String(tsnapshot.value as! Int)
        });
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
