//
//  AppointViewController.swift
//  email-to-calendar
//
//  Created by Joseph OConnor on 4/22/18.
//  Copyright © 2018 Joseph OConnor. All rights reserved.
//

import UIKit
import EventKit

class AppointViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var pendingAppTable: UITableView!
    @IBOutlet weak var autoAppTable: UITableView!
    
    let service = OutlookService.shared()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func addEventsButton(_ sender: Any) {
        //add events to calendar
        for i in 0..<(pendingAppTitle.count){
            addEvent(title: pendingAppTitle[i], startDate: pendingAppDate[i], notes: pendingAppNotes[i])
        }
        //clear table
        pendingAppTitle.removeAll()
        pendingAppDate.removeAll()
        pendingAppNotes.removeAll()
        
        //reload table view
        pendingAppTable.reloadData()
    }
    
    var autoAppTitle:[String] = []
    var autoAppDate:[Date] = []
    var autoAppNotes:[String] = []
    
    var pendingAppTitle:[String] = []
    var pendingAppDate:[Date] = []
    var pendingAppNotes:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Appointments"
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        
        /* service.extractFromMessage(subject: "Meeting notes", from: "madhumita.mazumder1995@gmail.com", content: "\r\n________________________________________\r\nFrom: Alex D\r\nSent: Sunday, October 19, 2014 5:28 PM\r\nTo: Katie Jordan\r\nSubject: Meeting Notes\r\n\r\n Meeting at 4-25-2018 11:20 \r\n")
         service.extractFromMessage(subject: "Meeting notes", from: "tarit.mazumder@gmail.com", content: "\r\n________________________________________\r\nFrom: Alex D\r\nSent: Sunday, October 19, 2014 5:28 PM\r\nTo: Katie Jordan\r\nSubject: Meeting Notes\r\n\r\n Meeting at 4-25-2018 11:20 \r\n")
 */
         
        
        //access favorite contacts
        var contacts:[String] = delegate.getContacts()
        
        //check for mail
        self.checkMail()
        
        
        //sort incoming appointments
        var newAppTitle:[String] = service.getAppTitles()
        var newAppDate:[Date] = service.getAppDates()
        var newAppNotes:[String] = service.getAppNotes()
        NSLog("new app title array: ")
        print(newAppTitle)
        
        for a in 0..<(newAppTitle.count){
            if(contacts.contains(newAppNotes[a])){
                autoAppTitle.append(newAppTitle[a])
                autoAppDate.append(newAppDate[a])
                autoAppNotes.append(newAppNotes[a])
            }
            else{
                pendingAppTitle.append(newAppTitle[a])
                pendingAppDate.append(newAppDate[a])
                pendingAppNotes.append(newAppNotes[a])
            }
        }
        
        
        //clear the singleton's data stream
        service.clearAll()
        
        //add all autoadded events to calendar
        for i in 0..<(autoAppTitle.count){
            addEvent(title: autoAppTitle[i], startDate: autoAppDate[i], notes: autoAppNotes[i])
        }
        
        
    }
    
    func checkMail() -> Void {
        
        service.getUserEmail() {
            email in
            if let unwrappedEmail = email {
                NSLog("Hello \(unwrappedEmail)")
           
        
 
        
        self.service.getInboxMessages() {
            messages in
            if let unwrappedMessages = messages {
                NSLog("check Mail called")
                NSLog("unwrapped messages count: ")
                print(unwrappedMessages.count)
                print(unwrappedMessages)
                for (message) in unwrappedMessages["value"].arrayValue {
                    NSLog(message["subject"].stringValue)
                    NSLog(message["from"]["emailAddress"]["address"].stringValue)
                    NSLog(message["body"]["content"].stringValue)
                    self.service.extractFromMessage(subject: message["subject"].stringValue, from: message["from"]["emailAddress"]["address"].stringValue, content: message["body"]["content"].stringValue)
                            NSLog("end extractFromMessage!")
                        }
                        NSLog("end for loop")
                    }
                    NSLog("end getInboxMessages1")
                   
                }
                NSLog("End getInboxMessages()")
            }
            NSLog("End getUserEmail()")
        }
        NSLog("End checkMail()")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == autoAppTable){
            return autoAppDate.count
        }
        else{
            return pendingAppDate.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        if(tableView == autoAppTable){
            let cell:UITableViewCell = UITableViewCell()
            cell.backgroundColor = UIColor(red: 0.61, green: 0.99, blue: 0.79, alpha: 1.0)
            cell.textLabel?.text = dateFormatter.string(from: autoAppDate[indexPath.row]) + " has been autoadded"
            return cell
        }
        else{
            let cell:UITableViewCell = UITableViewCell()
            cell.backgroundColor = UIColor(red: 1.00, green: 0.68, blue: 0.68, alpha: 1.0)
            cell.textLabel?.text = dateFormatter.string(from: pendingAppDate[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(tableView == pendingAppTable){
            pendingAppTitle.remove(at: indexPath.row)
            pendingAppDate.remove(at: indexPath.row)
            pendingAppNotes.remove(at: indexPath.row)
            pendingAppTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        pendingAppTable.setEditing(editing, animated: animated)
    }
    
    
    
    func addEvent(title:String, startDate:Date, notes:String){
        let eventStore:EKEventStore = EKEventStore()
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if((granted) && (error == nil))
            {
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = startDate + 3600
                event.notes = notes
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                }catch let error as NSError{
                    print("error1: \(error)")
                }
            }else{
                print("error2: \(error)")
                
                //alert
                let alert = UIAlertController(title: "Calendar Access Required",
                                              message: "Calendar permission is required to have the full functionlity of this app. Go to settings to change this.",
                                              preferredStyle: UIAlertControllerStyle.alert)
                
                //cancel button related action
                let cancel = UIAlertAction(title: "Cancel",
                                           style: UIAlertActionStyle.cancel,
                                           handler:nil)
                
                alert.addAction(cancel)
                
                self.present(alert,animated: true, completion: nil)
                
            }
        })
    }
    
    
}



