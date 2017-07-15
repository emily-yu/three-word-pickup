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
    
    // line data
    var lineText = [String]()
    var lineLike = [Int]()
    var lineUser = [String]()
    var lineKey = [String]()
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        ref = FIRDatabase.database().reference()
        super.viewDidLoad()
        self.loadData()
    }
    
    func loadData() {
        
        let likeRef = ref.child("lines")
        likeRef.observe(.value, with: { snapshot in
            
            for line in snapshot.children {
                self.lineText.append((line as AnyObject).key)
            }
            let count = Int(snapshot.childrenCount)
            print("COUNT:\(count)")
            
            // line is the key to navigate through
            for lines in self.lineText {
                
                // likes on each line
                likeRef.child(lines).child("likes").observe(.value, with: {
                    snapshot in
                    self.lineLike.append(snapshot.value as! Int)
                })
                
                // user on each line
                likeRef.child(lines).child("username").observe(.value, with: {
                    snapshot in
                    self.lineUser.append(snapshot.value as! String)
                })
                
                // user on each line
                likeRef.child(lines).child("keys").observe(.value, with: {
                    snapshot in
                    for line in snapshot.children {
                        self.lineKey.append((line as AnyObject).value)
                    }
                    if (self.lineLike.count == count) {
                        // reload data
                        print(self.lineText)
                        print(self.lineLike)
                        print(self.lineUser)
                        print(self.lineKey)
                    }
                })
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class RateCell: UITableViewCell {
}

