//
//  ContactsViewController.swift
//  email-to-calendar
//
//  Created by Joseph OConnor on 4/22/18.
//  Copyright © 2018 Joseph OConnor. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UITableViewDataSource{
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func addContact(_ sender: Any) {
        print("testing")
        triggerContactInfoAlert()
    }
    @IBOutlet weak var contactsTable: UITableView!
    var contacts:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Favorite Contacts"
        self.navigationItem.leftBarButtonItem = editButtonItem
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "contactCell")!
        cell.textLabel?.text = contacts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        contacts.remove(at: indexPath.row)
        delegate.setContacts(newContacts: contacts)
        contactsTable.deleteRows(at: [indexPath], with: .fade)
        saveData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        contactsTable.setEditing(editing, animated: animated)
    }
    
    func addContacts(text:String){
        let contactInfo:String = text
        contacts.insert(contactInfo, at: 0)
        delegate.setContacts(newContacts: contacts)
        let indexPath:IndexPath = IndexPath(row: 0, section: 0)
        contactsTable.insertRows(at: [indexPath], with: .automatic)
        saveData()
    }
    
    func saveData(){
        UserDefaults.standard.set(contacts, forKey: "contacts")
    }
    
    func loadData(){
        if let loaded = UserDefaults.standard.value(forKey: "contacts") as? [String] {
            contacts = loaded
            contactsTable.reloadData()
            delegate.setContacts(newContacts: contacts)
        }
    }
    
    func triggerContactInfoAlert() {
        //alert
        let alert = UIAlertController(title: "New Contact",
                                      message: "Enter contact's e-mail.",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        //cancel button related action
        let cancel = UIAlertAction(title: "Cancel",
                                   style: UIAlertActionStyle.cancel,
                                   handler:nil)
        
        alert.addAction(cancel)
        
        //ok button related action
        let ok = UIAlertAction(title: "OK",
                               style: UIAlertActionStyle.default){(action: UIAlertAction) -> Void in
                                let textField = alert.textFields?[0]
                                self.addContacts(text: (textField?.text)!)
                                
        }
        
        alert.addAction(ok)
        
        //text input related action
        alert.addTextField{(textField: UITextField) -> Void in
            textField.placeholder = "E-mail"
        }
        
        self.present(alert,animated: true, completion: nil)
        
    }
    
    
    
}

