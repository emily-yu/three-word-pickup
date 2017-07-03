//
//  ProfileController.swift
//  pickup-in-three
//
//  Created by Emily on 7/3/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit

class ProfileController: UIViewController {
    
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
        // Do any additional setup after loading the view, typically from a nib.
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
