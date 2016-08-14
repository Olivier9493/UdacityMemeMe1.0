//
//  MemeTextFieldDelegate.swift
//  MemeMe 1.0
//
//  Created by Olivier Becker on 11/08/16.
//  Copyright © 2016 pachyderme.li@oli4. All rights reserved.
//

import Foundation
import UIKit

class MemeTextFieldDelegate : NSObject, UITextFieldDelegate{
    
    /// As soon that we begin to edit a text the initial value of the text must be cleared
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text! == "TOP" || textField.text! == "BOTTOM"{
            textField.text = ""
        }
    }
    
    /// when the user hits "Return" the keyboard must disappear
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /// Converting all text entry in uppercase characters
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
       textField.text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string.uppercaseString)
        
        return false
        
    }
    
}
