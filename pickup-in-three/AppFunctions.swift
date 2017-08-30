//
//  AppFunctions.swift
//  pickup-in-three
//
//  Created by Emily on 8/30/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import Firebase

class appFunctions {
    
    var ref = FIRDatabase.database().reference();
    
    /* Add a reveal point to the user's account */
    func incrementPoints() {
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("points").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if let int = snapshot.value{
                let same = (int as! Int) + 1;
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("points").setValue(same);
            }
        }
    };
    
}
