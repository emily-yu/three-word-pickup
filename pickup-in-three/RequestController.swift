//
//  RequestController.swift
//  pickup-in-three
//
//  Created by Emily on 9/27/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit

class RequestController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // tableView -- START MARKER
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return contactNames.count
        return 2;
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RequestCell = self.tableView.dequeueReusableCell(withIdentifier: "RequestCell") as! RequestCell
        
        cell.first.text = "first"
        cell.second.text = "second"
        cell.third.text = "third"
        
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
