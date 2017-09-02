//
//  FirstViewController.swift
//  pickup-in-three
//
//  Created by Emily on 7/2/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class CreateController: UIViewController {

    @IBOutlet var textField: UITextView!
    
    @IBAction func refresh(_ sender: Any) {
        refreshAll();
    }
    
    @IBOutlet var word1: UIButton!
    @IBAction func word1(_ sender: Any) {
        self.textField.text = "\(textField.text!) \(self.word1.currentTitle!)";
    }
    
    @IBOutlet var word2: UIButton!
    @IBAction func word2(_ sender: Any) {
        self.textField.text = "\(textField.text!) \(self.word2.currentTitle!)";
    }
    
    @IBOutlet var word3: UIButton!
    @IBAction func word3(_ sender: Any) {
        // append word to textfield.content
        self.textField.text = "\(textField.text!) \(self.word3.currentTitle!)";
        print(word3.currentTitle!)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        // retrieve three random words
        // replace word1.content, word2.content, word3.content
    }
    
    @IBAction func submitButton(_ sender: Any) {
        if  (textField.text.lowercased().range(of: (word3.currentTitle?.lowercased())!) != nil) &&
            (textField.text.lowercased().range(of: (word3.currentTitle?.lowercased())!) != nil) &&
            (textField.text.lowercased().range(of: (word3.currentTitle?.lowercased())!) != nil) {
            
            // Generate new set of words
            refreshAll();
            
            print("TODO: Submit content to Firebase")
            // appFunctions().incrementPoints();
        }
        else {
            let alertController = UIAlertController(title: "Error", message: "Please use the above words to create your pickup line.", preferredStyle: .alert);
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
            alertController.addAction(defaultAction);
            
            present(alertController, animated: true, completion: nil);
        }
    }
    
    // Generate new set of words
    func refreshAll() {
        appFunctions().requestRandomWord(button: word1);
        appFunctions().requestRandomWord(button: word2);
        appFunctions().requestRandomWord(button: word3);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshAll();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

