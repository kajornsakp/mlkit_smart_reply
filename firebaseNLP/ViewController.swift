//
//  ViewController.swift
//  firebaseNLP
//
//  Created by Kajornsak Peerapathananont on 8/4/2562 BE.
//  Copyright © 2562 Kajornsak Peerapathananont. All rights reserved.
//

import UIKit
import FirebaseMLNLSmartReply
import MessageKit
import MessageInputBar

struct Message : MessageType {
    var sender: Sender
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

class ViewController: MessagesViewController {

    let sender = Sender(id: "me", displayName: "John")
    let sender2 = Sender(id: "her", displayName: "Jane")
    var isJohn = false
    var messages: [MessageType] = []
    var conversation : [TextMessage] = []
    var naturalLanguage : NaturalLanguage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = UIColor.blue
        messageInputBar.sendButton.tintColor = UIColor.blue
        
        naturalLanguage = NaturalLanguage.naturalLanguage()

    }

    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.title = named
                $0.tintColor = UIColor.blue
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                $0.setSize(CGSize(width: 50, height: 25), animated: false)
            }.onTouchUpInside { _ in
                print("Item Tapped \(named)")
                self.insertMessage(sender: self.isJohn ? self.sender : self.sender2, text: named)
                self.isJohn.toggle()
        }
    }
}

extension ViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> Sender {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }

}

extension ViewController : MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        self.insertMessage(sender: self.isJohn ? self.sender : self.sender2, text: text)
        self.isJohn.toggle()
        inputBar.inputTextView.text = String()
        
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func insertMessage(sender: Sender, text: String) {
        let date = Date.init()
        let message = Message(sender: sender, messageId: "1", sentDate: date, kind: .text(text))
        messages.append(message)
        conversation.append(TextMessage(text: text, timestamp: date.timeIntervalSince1970, userID: sender.id, isLocalUser: isJohn))
        messagesCollectionView.reloadData()
        handleSmartReply()
    }
    
    func handleSmartReply() {
        naturalLanguage.smartReply().suggestReplies(for: conversation) { result, error in
            guard error == nil, let result = result else {
                return
            }
            if (result.status == .notSupportedLanguage) {
                // The conversation's language isn't supported, so the
                // the result doesn't contain any suggestions.
            } else if (result.status == .success) {
                // Successfully suggested smart replies.
                // ...
                let suggestions = result.suggestions.map{return $0.text}
                let suggestionsView = suggestions.map { return self.makeButton(named: $0)}
                self.messageInputBar.setStackViewItems(suggestionsView, forStack: .top, animated: true)
            }
        }
    }
}




/*



 
 */

//messageInputBar.setStackViewItems([makeButton(named: text)], forStack: .top, animated: true)

