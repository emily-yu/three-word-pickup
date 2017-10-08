//
//  SearchController.swift
//  pickup-in-three
//
//  Created by Emily on 7/3/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SearchController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var ref: FIRDatabaseReference!
    var searchActive : Bool = false
    var dataKeys: [[String]] = []
    var dataStrings: [String] = []
    var data = ["San Francisco","New York","San Jose","Chicago","Los Angeles","Austin", "Seattle"]
    var filtered: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad();
        ref = FIRDatabase.database().reference();
        ref.child("lines").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for line in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                // this should be changed to a nicer iterator
                self.dataStrings.append(line.key);
                self.ref.child("lines").child(line.key).child("keys").observeSingleEvent(of: .value, with: { (snapshot) in
                    var keyArray: [String] = []
                    for lineasdf in snapshot.children {
                        keyArray.append((lineasdf as AnyObject).value);
                    }
                    self.dataKeys.append(keyArray);
                    self.tableView.reloadData()
                });

            }
        });
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        filtered.removeAll()
//        for dataPoint in data {
//            if ((dataPoint.lowercased().range(of: searchText.lowercased())) != nil) {
//                filtered.append(dataPoint);
//            }
//        }
        for (index, dataPoint) in dataKeys.enumerated() {
            keywordIterator: for keyword in dataPoint {
                if ((keyword.lowercased().range(of: searchText.lowercased())) != nil) {
                    filtered.append(dataStrings[index])
                    break keywordIterator
                }
            }
        }

        if (searchText == "") {
            searchActive = false;
            print("false")
            print(filtered)
        }
        else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchActive) {
            return filtered.count;
        }
//        return data.count;
        return dataStrings.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UITableViewCell;
        if (searchActive) {
            cell.textLabel?.text = filtered[indexPath.row];
        }
        else {
            cell.textLabel?.text = dataStrings[indexPath.row];
        }
        
        return cell;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

