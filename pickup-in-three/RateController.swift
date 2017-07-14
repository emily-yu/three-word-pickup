//
//  SecondViewController.swift
//  pickup-in-three
//
//  Created by Emily on 7/2/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class RateController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        self.loadData()
//        print("loaded")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loadData() {
        print("asdjklfajslkfjaslfkjlsadjfklasd")
//        ref = FIRDatabase.database().reference()
        ref.observe(.value, with: {
            snapshot in
            var restaurantNames = [String]()
            for restaurant in snapshot.children {
                restaurantNames.append((restaurant as AnyObject).key)
            }
            print(restaurantNames)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class RateCell: UITableViewCell {
}

