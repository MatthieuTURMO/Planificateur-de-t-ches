//
//  TachesTableViewController.swift
//  TaskPlan
//
//  Created by Matthieu Turmo on 25/01/2017.
//  Copyright © 2017 Matthieu Turmo. All rights reserved.
//

import UIKit
import os.log

class TachesTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var switchSorting: UISwitch!
    
    
    //liste des tâches qui se scrollent dans le table view
    var taches = [Taches]()
    var modeNuit:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        
        // Load any saved meals, otherwise load sample data.
        let savedTasks = loadTasks()
        if(savedTasks?.count == 0){
            // Load the sample data.
            loadSampleTaches()
        }
        else {
            taches += savedTasks!            
        }
        
        triPriority()
        
        //met en place le UIrefreshcontrol quand on scroll down en haut de la table view manuellement
        self.refreshControl?.addTarget(self, action: #selector(TachesTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        //appelle le thread pour le resfresh des données toutes les 120 s
        var timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: "reloadAffichage", userInfo: nil, repeats: true)
        
        //ajout du gesture recognizer long press
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(TachesTableViewController.longPressEdit(_:)))
        self.tableView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        
        //ajout du screen edge pan gesture recognizer pour relancer une tâche dépassée
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(TachesTableViewController.swipeRightGesture(_:)))
        swipeGesture.direction = UISwipeGestureRecognizerDirection.right
        self.tableView.addGestureRecognizer(swipeGesture)
        swipeGesture.delegate = self
        
        if(switchSorting.isOn){
            triPriority()
        }else{
            triDate()
        }
        
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 28/255.0, green: 188/255.0, blue: 156/255.0, alpha: 1.0)
        //rendre le barre de navigation touchable :
        let tapGestureRecognizerBarreNavigation = UITapGestureRecognizer(target:self, action: #selector(TachesTableViewController.somethingWasTapped(_:)))
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizerBarreNavigation)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return taches.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TachesTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TachesTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TachesTableViewCell.")
        }
        
        /*RECHERCHE DE LA DATE*/
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        /*DEFINITION DES ICONES/IMAGES*/
        let urgence1 = UIImage(named: "green")
        let urgence2 = UIImage(named: "orange")
        let urgence3 = UIImage(named: "red")
        let urgenceUndefined = UIImage(named:"gray")
        
        //fetching de la tache
        let tache = taches[indexPath.row]
        
        //l'icone est en fonction du rating
        //affichage de l'icone en fonction du rating de la tache (importance)
        if(tache.rating==0){
            cell.urgenceIcon.image = urgenceUndefined
        }else if(tache.rating==1){
            cell.urgenceIcon.image = urgence1
        }else if(tache.rating==2){
            cell.urgenceIcon.image = urgence2
        }else if(tache.rating == 3){
            cell.urgenceIcon.image = urgence3
        }else{
            fatalError("BAD RATING PHOTO")
        }
        
        //titre de la tache
        cell.TitreTache.text = tache.titre
        
        //date de la tache affichée en format lisible français
        cell.dateTeche.text = affichageDateCorrectement(date: tache.date)
        
        
        /*Calcul de temps restant entre la date de la tâche et la date courante*/
        //on récupère la date courante
        let currentDate = Date()
        //on récupère la différence entre la date courante et la date programmée de la tâche
        let (mois,_,_,_,secondes) = daysBetween(start: currentDate, end: tache.date)
        
        
        let (nbJours, nbHeures, nbMin, nbSec) = calculHeuresRestantes(secondes: secondes)
        /*Ici on va différencier l'affichage dans le temps restant, si mois>0 on affiche que le mois, si jour > 0 on affiche que le jour, sinon on affiche le temps restant heures/sec/min*/
        
        var stringAffichage:String
        
        if(mois>0){
            stringAffichage = "Dans \(mois) mois"
        }
        else{
            //on récupère le temps restant en j/h/min/s
            //pour ne pas brouiller l'affichage, si jours > 0, on n'affiche que le jour
            if(nbJours > 0){
                stringAffichage = "Dans \(nbJours)j \(nbHeures)h"
            }else{
                stringAffichage = "Dans \(nbHeures)h \(nbMin)m \(nbSec)s"
            }
        }
        
        //COULEUR DE l'AFFICHAGE en fonction du délai dépassé ou non, et selon l'activation du mode nuit
        if(modeNuit == 0){//mode nuit non activé
            if(mois < 0 || nbJours < 0 || nbMin < 0 || nbSec < 0 ){
                stringAffichage = "Délai dépassé"
                cell.tacheDepassee = 1
                cell.TitreTache.textColor = UIColor(red: 155/255.0, green: 89/255.0, blue: 182/255.0, alpha: 1.0)
                cell.backgroundColor = UIColor(red: 53/255.0, green: 73/255.0, blue: 94/255.0, alpha: 1.0)
            }else{
                cell.tacheDepassee = 0
                cell.TitreTache.textColor = UIColor(red: 155/255.0, green: 89/255.0, blue: 182/255.0, alpha: 1.0)
                cell.backgroundColor = UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0)
            }
        }
        else{
            if(mois < 0 || nbJours < 0 || nbMin < 0 || nbSec < 0 ){
                stringAffichage = "Délai dépassé"
                cell.tacheDepassee = 1
                cell.TitreTache.textColor = UIColor(red: 236/255.0, green: 240/255.0, blue: 241/255.0, alpha: 1.0)
                cell.backgroundColor = UIColor(red: 149/255.0, green: 165/255.0, blue: 166/255.0, alpha: 1.0)
            }else{
                cell.tacheDepassee = 0
                cell.TitreTache.textColor = UIColor(red: 236/255.0, green: 240/255.0, blue: 241/255.0, alpha: 1.0)
                cell.backgroundColor = UIColor(red: 230/255.0, green: 126/255.0, blue: 34/255.0, alpha: 1.0)
            }
        }
        
        
        
        
        //une fois le string créé, on le met dans le temps restant
        cell.tempsRestantLabel.text = stringAffichage
        //enfin on remplit la description de la tâche simplement
        cell.descriptionT = tache.descriptionT
        
        //si la tâche est à moins de 5 minutes du temps courant, on lève une alerte visuelle
        if(mois == 0 && nbJours == 0 && nbHeures == 0 && nbMin>=0 && nbMin<5 && nbSec>=0 && tache.alerteLevee == 0){
            gestionAlertes(titreTache: tache.titre)
            tache.alerteLevee = 1
        }
        
        return cell
    }
    
    
    
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            taches.remove(at: indexPath.row)
            saveTasks()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    
    // Override to support rearranging the table view.
   /* override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.taches[fromIndexPath.row]
        taches.remove(at: fromIndexPath.row)
        taches.insert(movedObject, at: destinationIndexPath.row)
    }*/
    
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    //MARK: Geture Recognizer
    
    //appui long sur une cellule
    func longPressEdit(_ recognizer: UILongPressGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizerState.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? TachesTableViewCell {
                    
                    //appui long : montre dans une alerte la description de la tâche
                    let alertController = UIAlertController(title: tappedCell.descriptionT, message: "", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                }
            }
        }
    }
    
    //gesture pan screen edge
    func swipeRightGesture(_ recognizer: UISwipeGestureRecognizer){
        if(recognizer.direction == UISwipeGestureRecognizerDirection.right){
            if recognizer.state == UIGestureRecognizerState.ended {
                let tapLocation = recognizer.location(in: self.tableView)
                if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                    if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? TachesTableViewCell {
                        if(tappedCell.tacheDepassee == 1){
                            //on récupère la date courante
                            let currentDate = Date()
                            
                            let dateDemain = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: currentDate)
                            taches[tapIndexPath.row].date = dateDemain!
                            self.tableView.reloadData()
                            tappedCell.tacheDepassee = 0
                            
                            if(switchSorting.isOn){
                                triPriority()
                            }else{
                                triDate()
                            }

                        }
                    }
                }
            }
        }
    }
    
    func somethingWasTapped(_ sth: AnyObject){
        modeNuit = toggleInt(val: modeNuit)
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "addTask":
            os_log("Adding a new task.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let tacheDetailViewController = segue.destination as? ViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedTacheCell = sender as? TachesTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedTacheCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedTache = taches[indexPath.row]
            tacheDetailViewController.tache = selectedTache
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
        
    }
    
    
    
    //MARK: Actions
    @IBAction func unwindToTachesList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ViewController, let tache = sourceViewController.tache {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                taches[selectedIndexPath.row] = tache
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                if(switchSorting.isOn){
                    triPriority()
                }else{
                    triDate()
                }
            }else {
                // Add a new meal.
                let newIndexPath = IndexPath(row: taches.count, section: 0)
                
                taches.append(tache)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                if(switchSorting.isOn){
                    triPriority()
                }else{
                    triDate()
                }
            }
            saveTasks()
        }
    }
    
    //change la méthode de tri en fonction de l'état du switch
    @IBAction func switchTriChangedState(_ sender: UISwitch) {
        if sender.isOn {
            triPriority() //tri en fonction de la priorité
        }else{
            triDate()
        }
    }
    
    
    //MARK: Refresh
    
    //Lance une alerte simple avec le titre de la tâche passée en paramètre
    func gestionAlertes(titreTache : String){
        let delayInSeconds = 5.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) { // 2
            let alertController = UIAlertController(title: titreTache, message: "Cette tâche est prévue dans moins de 5 minutes", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        if(switchSorting.isOn){
            triPriority()
        }else{
            triDate()
        }
        refreshControl.endRefreshing()
    }
    
    //reload l'affichage automatiquement toutes les 2 minutes
    func reloadAffichage(){
        let delayInSeconds = 30.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) { // 2
            self.tableView.reloadData()
        }
    }
    
    //MARK: Private Methods
    
    //fonction qui ordonne les tâches en fonction de leur priorité (rating)
    private func triPriority(){
        
        taches.sort() { $0.rating > $1.rating }
        self.tableView.reloadData()
    }
    
    //tri en fonction des dates croissantes (les plus proches en premier)
    private func triDate(){
        taches.sort() { $0.date < $1.date }
        self.tableView.reloadData()
    }
    
    
    
    //exemples de tâches si pas de tâches enregistrées
    private func loadSampleTaches() {
        //ici faut donc essayer de gérer l'icône affiché en fonction de rating
        
        let currentDate = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let someDateTime = formatter.date(from: "2017/02/15 10:55")
        let someDateTime1 = formatter.date(from: "2017/02/26 10:00")
        let someDateTime2 = formatter.date(from: "2017/05/11 12:05")
        let someDateTime3 = formatter.date(from: "2016/05/11 12:05")
        
        
        guard let tache1 = Taches(titre: "Aller chez le médecin", date: someDateTime!, rating: 3, lieu:"Rue d'auxonne", descriptionT:"Demander une ordonnance pour migraine.") else {
            fatalError("Unable to instantiate tache1")
        }
        
        guard let tache2 = Taches(titre: "Aller chez le coiffeur", date: someDateTime1!, rating: 2, lieu:"Place Wilson", descriptionT:"Pour avoir une coupe super belle") else {
            fatalError("Unable to instantiate tache2")
        }
        
        guard let tache3 = Taches(titre: "Appeler Alexis", date: someDateTime2!, rating: 0, lieu:"Pas de lieu", descriptionT:"Il faut qu'on ailler à Chinatown ensemble samedi") else {
            fatalError("Unable to instantiate tache3")
        }
        
        guard let tache4 = Taches(titre: "Réunion", date: someDateTime3!, rating: 2, lieu:"A l'ESIREM", descriptionT:"Samedi à l'ESIREM pour le gala, important") else {
            fatalError("Unable to instantiate tache3")
        }
        
        taches += [tache1,tache2,tache3,tache4]
    }
    
    //RETOURNE mois,jour,heures,minutes,secondes entre deux dates
    func daysBetween(start: Date, end: Date) -> (months: Int, days: Int, hours: Int, minutes: Int, seconds:Int) {
        
        //On récupère le nombre de mois et de jours entre les 2 dates
        let days =  Calendar.current.dateComponents([.day], from: start, to: end).day!
        let months = Calendar.current.dateComponents([.month], from: start, to: end).month!
        
        //ici on récupère l'heure entre les deux dates, puis on calcule les minutes <60, puis secondes <60
        let hours = Calendar.current.dateComponents([.hour], from: start, to: end).hour!
        
        
        let minutes = Calendar.current.dateComponents([.minute], from: start, to: end).minute!
        let seconds = Calendar.current.dateComponents([.second], from: start, to: end).second!
        
        return (months,days,hours,minutes,seconds)
    }
    
    /*Calcule, enfonction du nombre de secondes, le temps retant en jours/heure/min/secondes*/
    func calculHeuresRestantes(secondes:Int) -> (j: Int, h: Int, m: Int, s: Int){
        
        var secondesRestantes = secondes
        var nombreJours = 0, nombreHeures = 0, nombreMin = 0, nombreSec = 0
        
        //calcul nombre jours
        while(secondesRestantes >= 86400){
            secondesRestantes = secondesRestantes-86400
            nombreJours += 1
        }
        //calcul nombre heures
        while(secondesRestantes >= 3600){
            secondesRestantes = secondesRestantes-3600
            nombreHeures += 1
        }
        //calcul nombre minutes
        while(secondesRestantes >= 60){
            secondesRestantes = secondesRestantes-60
            nombreMin += 1
        }
        //les secondes restantes
        nombreSec = secondesRestantes
        
        return (nombreJours, nombreHeures, nombreMin, nombreSec)
    }
    
    //fonction qui affiche correctement la date passée en paramètre
    func affichageDateCorrectement(date:Date) -> String{
        //on récupère les éléments de la date
        let jours = Calendar.current.dateComponents([.day], from: date)
        let months = Calendar.current.dateComponents([.month], from: date)
        let hours = Calendar.current.dateComponents([.hour], from: date)
        let minutes = Calendar.current.dateComponents([.minute], from: date)
        let annee = Calendar.current.dateComponents([.year], from: date)
        
        //conversion en int pour l'affichage
        let intMonths = months.month
        let intJours = jours.day
        let intHours = hours.hour
        let intMinutes = minutes.minute
        let intYear = annee.year
        
        //en fonction du numéro du mois, on affiche son nom
        var stringMonths:String
        switch intMonths!{
        case 1:
            stringMonths = "Janvier"
        case 2:
            stringMonths = "Février"
        case 3:
            stringMonths = "Mars"
        case 4:
            stringMonths = "Avril"
        case 5:
            stringMonths = "Mai"
        case 6:
            stringMonths = "Juin"
        case 7:
            stringMonths = "Juillet"
        case 8:
            stringMonths = "Août"
        case 9:
            stringMonths = "Septembre"
        case 10:
            stringMonths = "Octobre"
        case 11:
            stringMonths = "Novembre"
        case 12:
            stringMonths = "Décembre"
        default:
            fatalError("Le mois est incorrect")
        }
        
        return "\(intJours!) \(stringMonths) \(intYear!) à \(intHours!)h\(intMinutes!)"
        
    }
    
    private func toggleInt(val: Int) -> Int{
        if(val == 0){
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: 241/255.0, green: 196/255.0, blue: 15/255.0, alpha: 1.0)
            return 1
        }else if(val == 1){
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: 28/255.0, green: 188/255.0, blue: 156/255.0, alpha: 1.0)
            return 0
        }else{
            fatalError("Toggle ni 0 ni 1 impossible")
        }
    }
    
    //LOAD AND SAVE FOR PERSIST DATA
    private func saveTasks(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(taches, toFile: Taches.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Tasks successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save tasks...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadTasks() -> [Taches]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Taches.ArchiveURL.path) as? [Taches]
    }
    
    
    
    
}
