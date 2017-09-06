//
//  AppFunctions.swift
//  pickup-in-three
//
//  Created by Emily on 8/30/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import SwiftyJSON

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
    
    /**
     * Request a new random word and change inner text of button
     * @param {UIButton} button - UIButton to assign new word value to
     */
    func requestRandomWord(button: UIButton) {
        Alamofire.request("http://api.wordnik.com/v4/words.json/randomWord?hasDictionaryDef=false&minCorpusCount=0&maxCorpusCount=-1&minDictionaryCount=1&maxDictionaryCount=-1&minLength=5&maxLength=-1&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5").responseJSON { response in
            debugPrint(response)
            
            if let json = response.data {
                let data = JSON(data: json)
                button.setTitle(String(describing: data["word"]), for: .normal);
            }
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard));
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap);
    }
    
    func dismissKeyboard() {
        view.endEditing(true);
    }
}
