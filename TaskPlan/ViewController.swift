//
//  ViewController.swift
//  TaskPlan
//
//  Created by Matthieu Turmo on 24/01/2017.
//  Copyright © 2017 Matthieu Turmo. All rights reserved.
//

import UIKit
import os.log
//controleur de la vue unique (pas le table view)
class ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var descriptionTache: UITextView!
    @IBOutlet weak var urgenceControl: Urgence!
    @IBOutlet weak var nomTacheTextField: UITextField!
    
    
    
    
    
    
    var tache:Taches?
    
    override func viewDidLoad() {
        //changement de la couleur de fond, c'est ici qu'on va changer en fonction de la priorité de la tâche/évènement
        self.view.backgroundColor = UIColor(red: 255/255.0, green: 222/255.0, blue: 173/255.0, alpha: 1.0)
        
        //La date minimum est la date/heure courante
        self.datePickerOutlet.minimumDate = Date()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        nomTacheTextField.delegate = self
        descriptionTache.delegate = self
        
        // Set up views if editing an existing Meal.
        if let tache = tache {
            navigationItem.title = tache.titre
            nomTacheTextField.text = tache.titre
            datePickerOutlet.date = tache.date
            descriptionTache.text = tache.descriptionT
            urgenceControl.rating = tache.rating
        }
        
        updateSaveButtonState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddTacheMode = presentingViewController is UINavigationController
        if isPresentingInAddTacheMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The ViewController is not inside a navigation controller.")
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        let titre = nomTacheTextField.text ?? ""
        let date = datePickerOutlet.date
        let descriptionT = descriptionTache.text ?? ""
        let rating = urgenceControl.rating
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        tache = Taches(titre: titre, date: date, rating: rating, lieu: "A CHANGER VIEWCONTROLLR PREPARE", descriptionT: descriptionT)
    }
    
    
    //MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: UITExtViewDelegate
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text.replacingOccurrences(of: "\n", with: "")

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = textView.text.replacingOccurrences(of: "\n", with: "")
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
                
        if(text == "\n"){
            textView.resignFirstResponder()
            
            return false
        }
        return true
    }
    
    
    //MARK: Actions
    
    //quand la date est changée
    @IBAction func datePickerTache(_ sender: UIDatePicker) {
        //cette partie faudra la mettre autre part pour récupérer la date de l'évènement et la mettre dans les cellules de du table view
        /*let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        self.TitreTache.text = dateFormatter.string(from: datePickerOutlet.date)*/
    }
    
    @IBAction func nomTacheEntre(_ sender: UITextField) {
        /*
        if(self.nomTacheTextField.text != ""){
            self.TitreTache.text = self.nomTacheTextField.text
        }else{
            self.TitreTache.text = "Titre de la tâche"
        } */       
    }
    
    
    //MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nomTacheTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    
    
    


}

