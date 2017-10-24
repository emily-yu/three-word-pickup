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
    var userLines: [String] = []
    var completedLoading = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        ref = FIRDatabase.database().reference();
        
        loadData();
    
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name(rawValue: "loadSearchData"), object: nil)
    }
    
    func loadData() {
        
        print(filtered)
        print(filteredKey)
        print(dataKeys)
        print(dataStrings)
        
        // complete list of lines
        dataStrings.removeAll()
        dataKeys.removeAll()
        userLines.removeAll();
        
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("favorites").observeSingleEvent(of: .value, with: { (snapshot) in
            for line in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.userLines.append(line.value as! String);
            }
        });
        
        
        ref.child("lines").observeSingleEvent(of: .value, with: { (snapshot) in
            let totalCount = snapshot.childrenCount
            for line in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                // this should be changed to a nicer iterator
                if !(self.dataStrings.contains(line.key)) {
                    self.dataStrings.append(line.key);
                }
//                self.dataStrings.append(line.key);
                self.ref.child("lines").child(line.key).child("keys").observeSingleEvent(of: .value, with: { (snapshot) in
                    var keyArray: [String] = []
                    for lineasdf in snapshot.children {
                        keyArray.append((lineasdf as AnyObject).value);
                    }
                    self.dataKeys.append(keyArray);
                    if (self.dataKeys.count == Int(totalCount)) {
                        self.tableView.delegate = self
                        self.tableView.dataSource = self
                        self.searchBar.delegate = self
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
        filteredKey.removeAll();
        for (index, dataPoint) in dataKeys.enumerated() {
            keywordIterator: for keyword in dataPoint {
                if ((keyword.lowercased().range(of: searchText.lowercased())) != nil
                    && index < dataPoint.count - 1
                    && !(filtered.contains(dataStrings[index]))) {
                    print(dataStrings[index])
                    print(dataKeys[index])
                    filtered.append(dataStrings[index])
                    filteredKey.append(dataKeys[index])
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
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // GET CURRENT TEXT
        var referenceArray: [String]
        
        if (filtered.indices.contains(indexPath.row)) {
            print(filtered[indexPath.row])
            referenceArray = filtered;
        }
        else {
            print(dataStrings[indexPath.row])
            referenceArray = dataStrings;
        }
        
        if (userLines.contains(referenceArray[indexPath.row])) {
            let alert = UIAlertController(title: "Error", message: "You already have favorited this line.", preferredStyle: .alert);
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil);
            alert.addAction(defaultAction);
            self.present(alert, animated: true, completion: nil);
        }
        else {
            let alertController = UIAlertController(title: "Confirm", message: "You are about to add this line from your favorites.", preferredStyle: .alert);
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
            alertController.addAction(cancelAction);
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.userLines.append(referenceArray[indexPath.row]);
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("favorites").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                    self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("favorites").child(String(snapshot.childrenCount)).setValue(referenceArray[indexPath.row]);
                }
            });
            alertController.addAction(defaultAction);
            
            self.present(alertController, animated: true, completion: nil);
        }
        
        favoriteReload = true;
        tableView.deselectRow(at: indexPath, animated: true);
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
