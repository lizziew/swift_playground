//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Elizabeth Wei on 6/14/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    var pollType: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        let controller: UIViewController
        if presentationStyle == .compact {
            controller = presentTemplatesCollectionViewController()
        }
        else {
            if conversation.selectedMessage == nil {
                controller = presentPollViewController()
            }
            else {
                let poll = Poll(message: conversation.selectedMessage)
                controller = presentVoteViewController(with: poll)
            }
        }
        
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
    }
    
    private func presentTemplatesCollectionViewController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: TemplatesCollectionViewController.storyboardIdentifier) as? TemplatesCollectionViewController else { fatalError("Unable to instantiate an TemplatesCollectionViewController from the storyboard") }
        controller.delegate = self
        return controller
    }
    
    private func presentPollViewController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: PollViewController.storyboardIdentifier) as? PollViewController else { fatalError("Unable to instantiate a PollViewController from the storyboard") }
        
        controller.pollType = self.pollType 
        controller.delegate = self
        
        return controller
    }
    
    private func presentVoteViewController(with: Poll) -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: VoteViewController.storyboardIdentifier) as? VoteViewController else { fatalError("Unable to instantiate an VoteViewController from the storyboard") }
        //controller.delegate = self
        return controller
    }
    
    private func composeMessage(dateText: String, pickerText: String, pollType: String, session: MSSession? = nil) -> MSMessage {
//        var components = URLComponents()
//        components.queryItems = iceCream.queryItems
        
        let layout = MSMessageTemplateLayout()
        
        
        layout.caption = "Vote for a " + pollType
        if pollType == "date" || pollType == "time" {
            layout.image = textToImage(drawText: dateText, inImage: UIImage(named:"blank")!, atPoint: CGPoint(x: 20, y: 60))
        }
        else {
            layout.image = textToImage(drawText: pickerText, inImage: UIImage(named:"blank")!, atPoint: CGPoint(x: 20, y: 60))
        }
        
        let message = MSMessage(session: session ?? MSSession())
//        message.url = components.url!
        message.layout = layout
        
        return message
    }
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.black()
        let textFont: UIFont = UIFont(name: "Helvetica Bold", size: 30)!
        
        //Setup the image context using the passed image.
        let scale = UIScreen.main().scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
}

extension MessagesViewController: TemplatesCollectionViewControllerDelegate {
    func templatesCollectionViewControllerDidSelectAdd(_ controller: TemplatesCollectionViewController, pollType: String) {
        self.pollType = pollType
        requestPresentationStyle(.expanded)
    }

}

extension MessagesViewController: PollViewControllerDelegate {
    func pollViewControllerDidSelectSend(_ controller: PollViewController) {
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        let dateText = controller.dateText
        let pickerText = controller.pickerText
        let pollType = controller.pollType
        
        let changeDescription = NSLocalizedString("We're in the process of voting", comment: "")
        let message = composeMessage(dateText: dateText, pickerText: pickerText, pollType: pollType!, session: conversation.selectedMessage?.session)
        
        conversation.insert(message, localizedChangeDescription: changeDescription) { error in
            if let error = error {
                print(error)
            }
        }
        
        dismiss()
    }
}

