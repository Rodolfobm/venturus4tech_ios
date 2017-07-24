//
//  ChatController.swift
//  Venturus4Tech
//
//  Created by Gustavo Reder Cazangi on 21/07/17.
//  Copyright © 2017 Venturus. All rights reserved.
//

import UIKit
import SocketIO
import AVFoundation

class ChatController : UIViewController, UITableViewDataSource {
    
    var userNick : String?;
    
    var socket : SocketIOClient?
    
    var player: AVAudioPlayer?
    
    var msgs : [[String: Any]] = [];
    
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        //Remove os separadores de celulas vazias...
        tableView.tableFooterView = UIView()
        if (isSoundEnabled()) {
            soundButton.setTitle("Som ON", for: .normal)
        } else {
            soundButton.setTitle("Som OFF", for: .normal)
        }
        getHistory()
        registerSocketEvents()
    }
    
    func registerSocketEvents() {
        socket?.on("messages") {data, ack in
            if let aMsg = data as? [[String: Any]]  {
                for i in 0..<aMsg.count {
                    self.msgs.append(aMsg[i])
                    self.updateTableView()
                }
            }
            if (self.isSoundEnabled()) {
                self.playSound()
            }
        }
    }
    
    func updateTableView() {
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: self.msgs.count-1, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    @IBAction func onSendClick(_ sender: Any) {
        var json : [String : Any] = [:];
        json["author"] = userNick
        json["message"] = inputTextField.text
        socket?.emit("messages", json)
    }
    
    func getHistory() {
        let url = URL(string: "http://192.168.2.117:3000/history")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            if let msgList = json as? [[String: Any]]  {
                self.msgs.append(contentsOf: msgList)
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: self.msgs.count-1, section: 0),
                                           at: .bottom, animated: true)
            }
        }
        
        task.resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula_chat", for: indexPath) as! ChatCell
        
        let pos = indexPath.row
        let msg = msgs[pos]
        let msgText = msg["message"] as? String
        
        cell.message.text = msgText
        cell.username.text = msg["author"] as? String
        cell.dateLabel.text = "\(msg["sent"] as! String)"
        cell.userInitial.text = "\(msgText!.characters.first!)"
        
        return cell
    }
 
    func playSound() {
        guard let url = Bundle.main.url(forResource: "msg_sound", withExtension: "mp3") else {
            print("error")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else {
                return
            }
            
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    @IBAction func onSoundButtonClick(_ sender: Any) {
        saveSoundPref()
        guard let button = sender as? UIButton else {
            return;
        }
        
        if (isSoundEnabled()) {
            button.setTitle("Som ON", for: .normal)
        } else {
            button.setTitle("Som OFF", for: .normal)
        }
    }
    
    @IBAction func onExitButtonClick(_ sender: Any) {
        socket?.disconnect()
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveSoundPref() {
        let defaults = UserDefaults.standard
        defaults.set(!isSoundEnabled(), forKey: "audio")
    }
    
    func isSoundEnabled() -> Bool {
        let defaults = UserDefaults.standard
        let enabled = defaults.bool(forKey: "audio")
        return enabled
    }
    
}
