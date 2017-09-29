//
//  RequestController.swift
//  pickup-in-three
//
//  Created by Emily on 9/27/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RequestController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    var requests: [[String]] = []
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = FIRDatabase.database().reference();
        ref.child("request").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for line in snapshot.children {
                if ((line as AnyObject).key != "0") {
                    let fields = ((line as AnyObject).value).components(separatedBy: .whitespaces).filter {!$0.isEmpty}
                    self.requests.append(fields);
                    self.tableView.reloadData();
                }
            }
        }
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // tableView -- START MARKER
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count;
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RequestCell = self.tableView.dequeueReusableCell(withIdentifier: "RequestCell") as! RequestCell
        
        cell.first.text = requests[indexPath.row][0];
        cell.second.text = requests[indexPath.row][1];
        cell.third.text = requests[indexPath.row][2];
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // tableView -- END MARKER
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class RequestCell: UITableViewCell {
    @IBOutlet var first: UILabel!
    @IBOutlet var second: UILabel!
    @IBOutlet var third: UILabel!
}
