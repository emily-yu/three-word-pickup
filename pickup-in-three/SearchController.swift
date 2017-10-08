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
    var filtered: [String] = []
    var filteredKey: [[String]] = []
    var completedLoading = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        ref = FIRDatabase.database().reference();
        ref.child("lines").observeSingleEvent(of: .value, with: { (snapshot) in
            let totalCount = snapshot.childrenCount
            for line in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                // this should be changed to a nicer iterator
                self.dataStrings.append(line.key);
                self.ref.child("lines").child(line.key).child("keys").observeSingleEvent(of: .value, with: { (snapshot) in
                    var keyArray: [String] = []
                    for lineasdf in snapshot.children {
                        keyArray.append((lineasdf as AnyObject).value);
                    }
                    self.dataKeys.append(keyArray);
                    if (self.dataKeys.count == Int(totalCount)) {
                        self.tableView.reloadData();
                        self.completedLoading = true
                    }
                });

            }
        });
    
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
        for (index, dataPoint) in dataKeys.enumerated() {
            keywordIterator: for keyword in dataPoint {
                if ((keyword.lowercased().range(of: searchText.lowercased())) != nil) {
                    print(dataStrings[index])
                    print(dataKeys[index])
                    filtered.append(dataStrings[index])
                    filteredKey.append(dataKeys[index])
                    break keywordIterator
                }
            }
        }

        if (searchText == "") {
            searchActive = false;
        }
        else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 0;
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchActive) {
            return filtered.count;
        }
        return dataStrings.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SearchCell? = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as? SearchCell
        
        if (searchActive) {
            cell?.lineText?.text = filtered[indexPath.row];
            cell?.word1?.text = filteredKey[indexPath.row][0];
            cell?.word2?.text = filteredKey[indexPath.row][1];
            cell?.word3?.text = filteredKey[indexPath.row][2];
        }
        else if (completedLoading) {
            cell?.lineText?.text = dataStrings[indexPath.row];
            cell?.word1?.text = dataKeys[indexPath.row][0];
            cell?.word2?.text = dataKeys[indexPath.row][1];
            cell?.word3?.text = dataKeys[indexPath.row][2];
        }
        else {
        }
        
        return cell!;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class SearchCell: UITableViewCell {
    @IBOutlet var lineText: UILabel!
    @IBOutlet var word1: UILabel!
    @IBOutlet var word2: UILabel!
    @IBOutlet var word3: UILabel!
}
