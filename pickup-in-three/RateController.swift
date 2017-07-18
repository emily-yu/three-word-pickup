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

class RateController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var ref: FIRDatabaseReference!
    let cellReuseIdentifier = "cell"
    
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
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func upvote(_ sender: Any) {
    }
    
    @IBAction func downvote(_ sender: Any) {
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
                        self.tableView.reloadData()
                    }
                })
            }
        })
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lineText.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RateCell = self.tableView.dequeueReusableCell(withIdentifier: "RateCell") as! RateCell

        cell.likes.text = String(lineLike[indexPath.row])
        cell.username.text = lineUser[indexPath.row]
        cell.line.text = lineText[indexPath.row]
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class RateCell: UITableViewCell {
    @IBOutlet var likes: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var line: UITextView!
}

