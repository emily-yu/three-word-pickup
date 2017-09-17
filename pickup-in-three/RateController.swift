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

// line data
var lineText = [String]()
var lineLike = [Int]()
var lineUser = [String]()
var lineKey = [String]()

class RateController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        ref = FIRDatabase.database().reference()
        super.viewDidLoad()
        self.loadData(tableView: tableView)
        
        // secondary function contacting
        NotificationCenter.default.addObserver(self, selector: #selector(loadData(tableView: UITableView)), name: NSNotification.Name(rawValue: "loadData"), object: nil)
        
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
        
        cell?.id = indexPath.row
        
        cell?.likes?.sizeToFit();
        cell?.likes?.text = String(lineLike[indexPath.row]);
        cell?.likes?.numberOfLines = 0
        
        cell?.username?.sizeToFit();
        cell?.username?.text = lineUser[indexPath.row];
        cell?.username?.numberOfLines = 0
        
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
        if (lineLike.count != 0) {
            let height:CGFloat = calculateHeight(inString: String(lineText[indexPath.row]))
            if (height + 20.0 < 64) {
                print("samefasjkdlf")
                return 90;
            }
            return height + 20.0
        }
        return 44;
    }
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    func loadData(tableView: UITableView) {
        
        print("ASDjfksdajfldsaf")
        
        lineText.removeAll()
        lineLike.removeAll()
        lineUser.removeAll()
        lineKey.removeAll()
        
        let likeRef = ref.child("lines")
        likeRef.observe(.value, with: { snapshot in
            
            for line in snapshot.children {
                lineText.append((line as AnyObject).key);
            }
            let count = Int(snapshot.childrenCount);
            
            // line is the key to navigate through
            for lines in lineText {
                
                // likes on each line
                likeRef.child(lines).child("likes").observe(.value, with: {
                    snapshot in
                    lineLike.append(snapshot.value as! Int);
                });
                
                // user on each line
                likeRef.child(lines).child("username").observe(.value, with: {
                    snapshot in
                    lineUser.append(snapshot.value as! String);
                });
                
                // user on each line
                likeRef.child(lines).child("keys").observe(.value, with: {
                    snapshot in
                    for line in snapshot.children {
                        lineKey.append((line as AnyObject).value)
                    }
                    if (lineLike.count == count) {
                        tableView.reloadData();
                    }
                });
            }
        });
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
    @IBAction func upvote(_ sender: Any) {
        ref.child("lines").child(lineText[id!]).child("likes").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if let int = snapshot.value {
                let same = (int as! Int) + 1;
                self.ref.child("lines").child(lineText[self.id!]).child("likes").setValue(same);
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadData"), object: nil, userInfo: [self.tableView()!: UITableView.self]);
                // refresh data
                // alert to tell that they upvoted?
            }
        }
    }
    @IBAction func downvote(_ sender: Any) {
        ref.child("lines").child(lineText[id!]).child("likes").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if let int = snapshot.value {
                let same = (int as! Int) - 1;
                if (same != 0) {
                    self.ref.child("lines").child(lineText[self.id!]).child("likes").setValue(same);
                    // refresh data
                    // alert to tell that they upvoted?
                }
                else {
                    // alert to tell them they can't
                }
            }
        }
    }
}

