//
//  ChatController.swift
//  Venturus4Tech
//
//  Created by Gustavo Reder Cazangi on 21/07/17.
//  Copyright © 2017 Venturus. All rights reserved.
//

import UIKit

class ChatController : UIViewController {
    
    var userNick : String?;
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = userNick
    }
    
    @IBAction func onSendClick(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
