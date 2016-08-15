//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Olivier Becker on 11/08/16.
//  Copyright © 2016 pachyderme.li@oli4. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    
    //#MARK: - All needed Outlets
    @IBOutlet weak var toolBarBottom: UIToolbar!
    @IBOutlet weak var toolBarTop: UIToolbar!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBottom: UITextField!

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    //#MARK: - Addtional global Variables
    let memeTextFieldDelegate = MemeTextFieldDelegate()
    
    //#MARK: - ViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign the delegate
        textFieldTop.delegate = self.memeTextFieldDelegate
        textFieldBottom.delegate = self.memeTextFieldDelegate
        
        // Check if a camera is available and update the enabling of the camera button
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        // at the begin the share button must be set on unabled
        shareButton.enabled = false
        
        // Initialize the textfields
        
        textFieldTop = initializeTextFields(textFieldTop, text: "TOP")
        textFieldBottom = initializeTextFields(textFieldBottom, text: "BOTTOM")

    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotification()
    }

    //#MARK: - Defined Actions
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        
        pickAnImage(.PhotoLibrary)

        }
    
    
    @IBAction func pickAnImageWithCamera(sender: AnyObject) {
        
        pickAnImage(.Camera)
        
    }

    
    @IBAction func shareAction(sender: AnyObject) {
        
        // We genrate first a "memed Image"
        let memedImage = generateMemeImage()
        
        // We pass the "memed Image" to the activty item
        let activityItems = [memedImage]
        
        // We define an instance of the ActivityViewController
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // We present the activity view
        self.presentViewController(activityController, animated: true, completion: nil)
        
        // We define the completion handler
        activityController.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
            if completed{
                let meme = Meme(topText: self.textFieldTop.text!, bottomText: self.textFieldBottom.text!, image: self.imageView.image!, memedImage: memedImage)

                /// we dismiss the activity Controller
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        
    }
    
    @IBAction func CancelAction(sender: AnyObject) {
        imageView.image = nil
        textFieldTop = initializeTextFields(textFieldTop, text: "TOP")
        textFieldBottom = initializeTextFields(textFieldBottom, text: "BOTTOM")
        shareButton.enabled = false
    }
    

    
    
    //#MARK: - Delegate Functions
    
    //For UIImagePickerController
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = image
            shareButton.enabled = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //#MARK: - Addtional methods
    
    
    /// Initialize the textfields
    func initializeTextFields( textfield: UITextField, text:String ) -> UITextField{
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: 3.0]
        
        // Set the text attributes
        textfield.defaultTextAttributes = memeTextAttributes
        
        // Set the text alignment
        textfield.textAlignment = .Center
        
        // Set the content of the textfield
        textfield.text = text
        
        return textfield
    }
    
    
    /// Generation of a "Memed Image"
    func generateMemeImage() -> UIImage{
        
        // We hide first the toolbars
        toolBarTop.alpha = 0.0
        toolBarBottom.alpha = 0.0
        
        // Creating the MemedImage
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let imageMemed: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // We show again the toolbars, now that the image is generated
        toolBarTop.alpha = 1.0
        toolBarBottom.alpha = 1.0
        
        return imageMemed
        
    }
    
    /// Keyboard Notififcation Subscription
    func subscribeToKeyboardNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /// Keyboard Notification Unsubsciption
    func unsubscribeFromKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /// Function to move view when the keyboard shows up
    func keyboardWillShow(notification: NSNotification){
        
        // We will move the view only if the bottom text is edited
        if textFieldBottom.editing{
        view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    /// Function to move the view back when the keyboard hides
    func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y = 0
    }
    
    /// function to get the keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    /// Function for the pick code
    func pickAnImage(sourceType:  UIImagePickerControllerSourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    
}

