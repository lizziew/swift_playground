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
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        pollType = nil
    }
    
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        let controller: UIViewController
        if presentationStyle == .compact {
            controller = presentTemplatesCollectionViewController()
        }
        else {
            if conversation.selectedMessage == nil {
                print("no selected message")
                if pollType == nil {
                    print("no poll type")
                    controller = presentEmptyViewController()
                }
                else {
                    print("poll type is \(pollType)")
                    controller = presentPollViewController()
                }
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
    
    private func presentEmptyViewController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: EmptyViewController.storyboardIdentifier) as? EmptyViewController else { fatalError("Unable to instantiate an EmptyViewController from the storyboard") }
        return controller
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
        controller.delegate = self
        return controller
    }
    
//    private func composeMessage(id: CKRecordID, session: MSSession? = nil) -> MSMessage {
//        //var components = URLComponents()
//        //components.queryItems = iceCream.queryItems
//        
//        let layout = MSMessageTemplateLayout()
//        
//        let database = CKContainer.default().privateCloudDatabase
//        database.fetch(withRecordID: id) { (pollRecord, error) in
//            if error != nil {
//                print(error)
//            }
//            else if pollRecord != nil {
//                let pollType = (pollRecord!["pollType"] as? String)!
//                
//                layout.caption = "Vote for a " + pollType
//                
//                let imgTitle = pollType + "_msg"
//                layout.image = UIImage(named: imgTitle)
//                
//                
//                //message.url = components.url!
//                message.layout = layout
//            }
//        }
//        
//        let message = MSMessage(session: session ?? MSSession())
//        
//        
//        
//        
//        
//        
//        return message
//    }
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
        let pollType = controller.pollType
        
        let pickerData = controller.currPickerOptions
        let dateData = controller.currDateOptions
        
        //store in iCloud
//        let pollRecord = CKRecord(recordType: "Poll")
//        let database = CKContainer.default().privateCloudDatabase
//        
//        pollRecord.setObject(pollType, forKey: "pollType")
//        if pickerData.count > 0 {
//            pollRecord.setObject(pickerData, forKey: "pickerData")
//        }
//        else if dateData.count > 0 {
//            pollRecord.setObject(dateData, forKey: "dateData")
//        }
//        
//        database.save(pollRecord) { (record, error) in
//            if error != nil {
//                print(error)
//            }
//        }
        
        let changeDescription = NSLocalizedString("We're in the process of voting", comment: "")
        //let message = composeMessage(id: pollRecord.recordID, session: conversation.selectedMessage?.session)
        
//        conversation.insert(message, localizedChangeDescription: changeDescription) { error in
//            if let error = error {
//                print(error)
//            }
//        }
        
        dismiss()
    }
}

extension MessagesViewController: VoteViewControllerDelegate {
    func voteViewControllerDidSelectVote(_ controller: VoteViewController) {
        
    }
}

