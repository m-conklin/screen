//
//  PostViewController.swift
//  personality
//
//  Created by Martin Conklin on 2016-08-14.
//  Copyright © 2016 Martin Conklin. All rights reserved.
//

import UIKit
import FBSDKShareKit

class PostViewController: UIViewController, UITextViewDelegate {
    
    let initialPlaceholderText = "What is on your mind?"
    var analyzedTone: Tone?

    @IBOutlet weak var textToPost: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textToPost.delegate = self
        
        applyPlaceholderStyle(textToPost, placeholderText: initialPlaceholderText)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostViewController.segueToTone(_:)), name: "ToneAnalyzed", object: nil)    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func applyPlaceholderStyle(postTextView: UITextView, placeholderText: String) {
        postTextView.textColor = UIColor.lightGrayColor()
        postTextView.text = placeholderText
    }
    
    private func applyTypingStyle(postTextView: UITextView) {
        postTextView.textColor = UIColor.darkTextColor()
        postTextView.alpha = 1.0
    }
    
    @objc internal func textViewShouldBeginEditing(postTextView: UITextView) -> Bool {
        if postTextView == textToPost && postTextView.text == initialPlaceholderText {
            moveCursorToStart(postTextView)
        }
        return true
    }
    
    private func moveCursorToStart(postTextView: UITextView) {
        dispatch_async(dispatch_get_main_queue()) {
            postTextView.selectedRange = NSMakeRange(0, 0)
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newlength = textView.text.utf16.count + text.utf16.count - range.length
        if newlength > 0 {
            if textView == textToPost && textView.text == initialPlaceholderText {
                if text.utf16.count == 0 {
                    return false
                }
                applyTypingStyle(textView)
                textView.text = ""
            }
            return true

        } else {
            applyPlaceholderStyle(textView, placeholderText: initialPlaceholderText)
            moveCursorToStart(textView)
            return false
        }
    }
    
    
    @IBAction func didTapPostButton(sender: UIButton) {
        if textToPost.text != initialPlaceholderText {
            let toneAnalyzer = WatsonToneAnalyzer()
            toneAnalyzer.analyzeTone(textToPost.text)
//            performSegueWithIdentifier("analyzePostTone", sender: nil)
//            FacebookHandler.sharedInstance.postToFeed(textToPost.text)
        }
    }
    
    @objc private func segueToTone(notification: NSNotification) {
        analyzedTone = (notification.userInfo!["tone" as NSObject] as! Tone)
        performSegueWithIdentifier("analyzePostTone", sender: nil)
    }
    
    @objc private func clearTextView() {
        applyPlaceholderStyle(textToPost, placeholderText: initialPlaceholderText)
    }
    
    
    @IBAction func unwindPostToFacebook(segue: UIStoryboardSegue) {
        FacebookHandler.sharedInstance.postToFeed(textToPost.text)
        clearTextView()
    }
    
    @IBAction func unwindDoNotPost(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func clearButtonTapped(sender: UIButton) {
        clearTextView()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        textToPost.delegate = nil
        if segue.identifier == "analyzePostTone" {
            let tonesViewController = segue.destinationViewController as! TonesViewController
            tonesViewController.analyzedTone = analyzedTone
        }
    }
    

}
