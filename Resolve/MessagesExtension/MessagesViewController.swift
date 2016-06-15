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
            let poll = Poll(message: conversation.selectedMessage)
            controller = presentPollViewController(with: poll)
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
    
    private func presentPollViewController(with poll: Poll) -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: PollViewController.storyboardIdentifier) as? PollViewController else { fatalError("Unable to instantiate a PollViewController from the storyboard") }
        
        controller.pollType = self.pollType 
        //controller.delegate = self
        
        return controller
    }
        
}

extension MessagesViewController: TemplatesCollectionViewControllerDelegate {
    func templatesCollectionViewControllerDidSelectAdd(_ controller:TemplatesCollectionViewController, pollType: String) {
        self.pollType = pollType
        requestPresentationStyle(.expanded)
    }

}

