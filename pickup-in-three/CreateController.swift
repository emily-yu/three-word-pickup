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

    @IBOutlet var scrollView: UIScrollView!
    
    // Random Word creation
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
        self.textField.text = "\(textField.text!) \(self.word3.currentTitle!)";
    }
    @IBAction func submitButton(_ sender: Any) {
        if  (textField.text.lowercased().range(of: (word1.currentTitle?.lowercased())!) != nil) &&
            (textField.text.lowercased().range(of: (word2.currentTitle?.lowercased())!) != nil) &&
            (textField.text.lowercased().range(of: (word3.currentTitle?.lowercased())!) != nil) {
            refreshAll(); // Generate new set of words
            // appFunctions().incrementPoints();
            print("TODO: Submit to Firebase");
        }
        else {
            let alertController = UIAlertController(title: "Error", message: "Please use the above words to create your pickup line.", preferredStyle: .alert);
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
            alertController.addAction(defaultAction);
            present(alertController, animated: true, completion: nil);
        }
    }
    
    // Brainstorm creation
    @IBOutlet var keyword1: UITextField!
    @IBOutlet var keyword2: UITextField!
    @IBOutlet var keyword3: UITextField!
    @IBOutlet var createTextField: UITextView!
    @IBAction func createSubmitButton(_ sender: Any) {
        if  (keyword1.text != "") &&
            (keyword2.text != "") &&
            (keyword3.text != "") &&
            (createTextField.text.lowercased().range(of: keyword1.text!.lowercased()) != nil) &&
            (createTextField.text.lowercased().range(of: keyword2.text!.lowercased()) != nil) &&
            (createTextField.text.lowercased().range(of: keyword3.text!.lowercased()) != nil) {
            print("TODO: Submit to Firebase");
        }
    }
    @IBAction func clearFields(_ sender: Any) {
        keyword1.text = "";
        keyword2.text = "";
        keyword3.text = "";
    }
    
    // Generate new set of words
    func refreshAll() {
        appFunctions().requestRandomWord(button: word1);
        appFunctions().requestRandomWord(button: word2);
        appFunctions().requestRandomWord(button: word3);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)
        refreshAll();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

