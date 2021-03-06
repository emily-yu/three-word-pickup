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
import UIKit

struct userDetails {
    static let username = ""
    static let password = ""
}

class appFunctions {
    
    var ref = FIRDatabase.database().reference();
    var favoritedLines: [String] = [];
    var postedLines: [String] = [];
    
    /* Add a point to the user's account */
    func incrementPoints() {
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("points").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if let pointVal = snapshot.value{
                let newVal = (pointVal as! Int) + 1;
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("points").setValue(newVal);
            }
        }
    };
    
    /**
     * Request a new random word and change inner text of button
     * @param {UIButton} button - UIButton to assign new word value to
     */
    func requestRandomWord(button: UIButton) {
        Alamofire.request("http://api.wordnik.com/v4/words.json/randomWord?hasDictionaryDef=false&minCorpusCount=0&maxCorpusCount=-1&minDictionaryCount=1&maxDictionaryCount=-1&minLength=5&maxLength=-1&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5").responseJSON { response in
            debugPrint(response);
            
            if let json = response.data {
                let data = JSON(data: json);
                button.setTitle(String(describing: data["word"]), for: .normal);
            }
        }
    }
    
    /**
     * Retrieve update data for user's favorited lines
     * @returns [String]
     */
//    func refreshFavorites() -> [String] {
//        postedLines.removeAll();
//        ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("lines").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
//            for line in snapshot.children {
//                self.postedLines.append(line as! String);
//                if (postedLines.count == snapshot.childrenCount - 1) {
//                    return postedLines;
//                }
//            }
//        }
//    }
    
    /**
     * Retrieve update data for user's posted lines
     * @returns [String]
     */
    func refreshUserLines() -> [String] {
        return ["asdf"];
    }
    
    /**
     * Transitions with a cross dissolve animation
     * @returns void
     */
    func fadeTransition(identifier: String) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let ivc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier);
            ivc.modalPresentationStyle = .custom
            ivc.modalTransitionStyle = .crossDissolve
            topController.present(ivc, animated: true, completion: { _ in })
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
