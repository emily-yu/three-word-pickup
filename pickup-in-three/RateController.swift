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

class RateController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var ref: FIRDatabaseReference!
    
    // line data
    var lineText = [String]();
    var lineLike = [Int]();
    var lineUser = [String]();
    
    var userLines: [String] = [];
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        ref = FIRDatabase.database().reference();
        super.viewDidLoad();
        self.loadData();
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name(rawValue: "loadRateData"), object: nil)
        
        // user favorite lines
        userLines.removeAll();
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("favorites").observeSingleEvent(of: .value, with: { (snapshot) in
            for line in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.userLines.append(line.value as! String);
            }
        });
        
        // set up the tableView
        let cellReuseIdentifier = "cell";
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lineLike.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : RateCell? = self.tableView.dequeueReusableCell(withIdentifier: "RateCell") as? RateCell
        if (cell == nil) {
            cell = RateCell(style:UITableViewCellStyle.default, reuseIdentifier: "RateCell");
            cell?.selectionStyle = UITableViewCellSelectionStyle.none;
        }
        
        cell?.id = indexPath.row;
        
        cell?.likes?.sizeToFit();
        cell?.likes?.text = String(lineLike[indexPath.row]);
        cell?.likes?.numberOfLines = 0;
        
        cell?.username?.sizeToFit();
        self.ref.child("users").child(lineUser[indexPath.row]).child("username").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            cell?.username?.text = snapshot.value as? String
            cell?.username?.numberOfLines = 0;
        }
        
        cell?.line?.sizeToFit();
        cell?.line?.text = lineText[indexPath.row];
        
        return cell!;
    }
    
    func calculateHeight(inString:String) -> CGFloat {
        let messageString = inString
        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 15.0)];
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes);
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: 200.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil);
        let requredSize:CGRect = rect;
        return requredSize.height;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (lineLike.count != 0 && indexPath.row < lineLike.count) {
            let height:CGFloat = calculateHeight(inString: String(lineText[indexPath.row]))
            if (height + 20.0 < 64) {
                return 90;
            }
            return height + 20.0
        }
        return 44;
    }
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (userLines.contains(lineText[indexPath.row])) {
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
                self.userLines.append(self.lineText[indexPath.row]);
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("favorites").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("favorites").child(String(snapshot.childrenCount)).setValue(self.lineText[indexPath.row]);
                }
            });
            alertController.addAction(defaultAction);
            
            self.present(alertController, animated: true, completion: nil);
        }
        
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    func loadData() {
        lineText.removeAll();
        lineLike.removeAll();
        lineUser.removeAll();
        
        let likeRef = ref.child("lines");
        likeRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                guard let restDict = rest.value as? [String: Any] else { continue }
                let user = restDict["username"] as? String; // lineUser
                let text = rest.key // lineText
                let like = restDict["likes"] as? Int
                self.lineUser.append(user!);
                self.lineText.append(text);
                self.lineLike.append(like!);
            }
            self.tableView.reloadData()
        }
    }

    // check if user has already upvoted
    @IBAction func upvote(_ sender: Any) {
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("liked").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            let count = snapshot.childrenCount
            if let cell = (sender as AnyObject).superview??.superview as? RateCell {
                let indexPath = self.tableView.indexPath(for: cell);
                let cellIndex = indexPath?.row
                var exists = false;
                
                for line in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    if (line.value as? String == self.lineText[(indexPath?.row)!]) {
                        exists = true;
                    }
                }
                
                if !(exists) {
                    self.ref.child("lines").child(self.lineText[(indexPath?.row)!]).child("likes").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                        if let int = snapshot.value {
                            let same = (int as! Int) + 1;
                            print(self.lineText[(indexPath?.row)!])
                            self.ref.child("lines").child(self.lineText[(indexPath?.row)!]).child("likes").setValue(same);
                            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("liked").child(String(count)).setValue(self.lineText[(indexPath?.row)!])
                            self.lineLike[cellIndex!] = same
                            self.tableView.reloadData();
                        }
                    }
                }
                else {
                    let alert = UIAlertController(title: "Error", message: "You already have rated this line.", preferredStyle: .alert);
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil);
                    alert.addAction(defaultAction);
                    self.present(alert, animated: true, completion: nil);
                }
                
            }
        }
    }
    
    @IBAction func downvote(_ sender: Any) {
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("liked").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            let count = snapshot.childrenCount
            if let cell = (sender as AnyObject).superview??.superview as? RateCell {
                let indexPath = self.tableView.indexPath(for: cell);
                let cellIndex = indexPath?.row
                var exists = false;
                
                for line in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    if (line.value as? String == self.lineText[(indexPath?.row)!]) {
                        exists = true;
                    }
                }

                if !(exists) {
                    self.ref.child("lines").child(self.lineText[(indexPath?.row)!]).child("likes").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                        if let int = snapshot.value {
                            let same = (int as! Int) - 1;
                            print(self.lineText[(indexPath?.row)!])
                            self.ref.child("lines").child(self.lineText[(indexPath?.row)!]).child("likes").setValue(same);
                            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("liked").child(String(count)).setValue(self.lineText[(indexPath?.row)!])
                            self.lineLike[cellIndex!] = same
                            self.tableView.reloadData();
                        }
                    }
                }
                else {
                    let alert = UIAlertController(title: "Error", message: "You already have rated this line.", preferredStyle: .alert);
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil);
                    alert.addAction(defaultAction);
                    self.present(alert, animated: true, completion: nil);
                }
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class RateCell: UITableViewCell {
    
    var id: Int?
    var ref = FIRDatabase.database().reference();
    
    func tableView() -> UITableView? {
        var currentView: UIView = self
        while let superView = currentView.superview {
            if superView is UITableView {
                return (superView as! UITableView)
            }
            currentView = superView
        }
        return nil
    }
    
    @IBOutlet var likes: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var line: UITextView!

}

