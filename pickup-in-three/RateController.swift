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
    var lineText = [String]()
    var lineLike = [Int]()
    var lineUser = [String]()
    var lineKey = [String]()
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        ref = FIRDatabase.database().reference()
        super.viewDidLoad()
        self.loadData()
        
        // set up the tableView
        let cellReuseIdentifier = "cell";
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
    @IBAction func upvote(_ sender: Any) {
    }
    
    @IBAction func downvote(_ sender: Any) {
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
                        self.tableView.reloadData();
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
    @IBOutlet var likes: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var line: UITextView!
}

