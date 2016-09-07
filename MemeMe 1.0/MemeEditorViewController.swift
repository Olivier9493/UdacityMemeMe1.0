//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Olivier Becker on 11/08/16.
//  Copyright © 2016 pachyderme.li@oli4. All rights reserved.
//
    
import UIKit
import AVFoundation

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
    var textFieldTopOriginY: CGFloat = 0.0
    var textFieldBottomOriginY: CGFloat = 0.0
    var topConstraint: NSLayoutConstraint!
    var bottomConstraint: NSLayoutConstraint!

    
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
        
        // Get the original position of the text fields
        textFieldBottomOriginY = textFieldBottom.frame.origin.y
        textFieldTopOriginY = textFieldTop.frame.origin.y
        
        // Initialize the textfields
        textFieldTop = initializeTextFields(textFieldTop, text: "TOP", originY: textFieldTopOriginY)
        textFieldBottom = initializeTextFields(textFieldBottom, text: "BOTTOM", originY: textFieldBottomOriginY)
        
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
        textFieldTop = initializeTextFields(textFieldTop, text: "TOP", originY: textFieldTopOriginY)
        textFieldBottom = initializeTextFields(textFieldBottom, text: "BOTTOM", originY: textFieldBottomOriginY)
        updateTextfieldPosition()
        shareButton.enabled = false
    }
    

    
    
    //#MARK: - Delegate Functions
    
    //For UIImagePickerController
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = image
            // Update the position of the text
            updateTextfieldPosition()
            shareButton.enabled = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //#MARK: - Addtional methods
    
    
    /// Initialize the textfields
    func initializeTextFields( textfield: UITextField, text:String, originY:CGFloat ) -> UITextField{
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.redColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 50)!,
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
        let imageMemed: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
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
            
            // First we remove the existing Constraints
            if topConstraint != nil{
                view.removeConstraint(topConstraint)
            }
            
            if bottomConstraint != nil{
                view.removeConstraint(bottomConstraint)
            }
        view.frame.origin.y = -getKeyboardHeight(notification)
        updateTextfieldPosition()
        }
    }
    
    /// Function to move the view back when the keyboard hides
    func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y = 0
        updateTextfieldPosition()
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
    
    ///Update the position of the textfields according to the position of the view image
    func updateTextfieldPosition(){
     

 
        // First we remove the existing Constraints
        if topConstraint != nil{
            view.removeConstraint(topConstraint)
        }

        if bottomConstraint != nil{
            view.removeConstraint(bottomConstraint)
        }
 
        
        // We need to get the position of the image inside of imageView
        let size = imageView.image != nil ? imageView.image!.size : imageView.frame.size
        let frame = AVMakeRectWithAspectRatioInsideRect(size, view.bounds)
        
        // We determine the margin for the new constraints : 3 % of the height of the frame
        // let margin = frame.origin.y + frame.size.height * 0.03
        let margin = frame.size.height * 0.1
        

        // we create the new contrainsts
        
        topConstraint = NSLayoutConstraint(
            item: textFieldTop,
            attribute : .Top,
            relatedBy: .Equal,
            toItem: imageView,
            attribute: .Top,
            multiplier: 1.0,
            constant: margin)
        view.addConstraint(topConstraint)
 
        
        bottomConstraint = NSLayoutConstraint(
            item: textFieldBottom,
            attribute : .Bottom,
            relatedBy: .Equal,
            toItem: imageView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: -margin)
        view.addConstraint(bottomConstraint)

        
    }
    
    
}

