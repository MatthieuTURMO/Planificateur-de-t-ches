//
//  RatingControl.swift
//  FoodTracker
//
//  Created by Matthieu Turmo on 14/12/2016.
//  Copyright © 2016 Matthieu Turmo. All rights reserved.
//

import UIKit

@IBDesignable class Urgence: UIStackView {
    //MARK: Properties
    private var urgenceIcons = [UIButton]()
    var rating = 0{
        didSet {
            updateButtonSelectionStates()
            updateColor()
        }
    }
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0){
        didSet{
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 3{
        didSet{
            setupButtons()
        }
    }
    
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    
    //MARK: Button Action
    func ratingButtonTapped(button: UIButton) {
        guard let index = urgenceIcons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(urgenceIcons)")
        }
        
        // Calculate the rating of the selected button
        let selectedRating = index + 1
        
        if selectedRating == rating {
            // If the selected star represents the current rating, reset the rating to 0.
            rating = 0
        } else {
            // Otherwise set the rating to the selected star
            rating = selectedRating
        }
    }
    
    
    private func setupButtons() {
        
        // Clear any existing buttons
        for button in urgenceIcons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        urgenceIcons.removeAll()
        
        // Load Button Images
        let bundle = Bundle(for: type(of: self))
        let grayIcon = UIImage(named:"gray", in: bundle, compatibleWith: self.traitCollection)
        
        for index in 0..<starCount {
            // Initialisation des boutons en gris
            let button = UIButton()
            button.setImage(grayIcon, for: .normal)
            button.setImage(grayIcon, for: .selected)
            button.setImage(grayIcon, for: .highlighted)
            button.setImage(grayIcon, for: [.highlighted, .selected])
           
            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Setup the button action
            button.addTarget(self, action: #selector(Urgence.ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the new button to the rating button array
            urgenceIcons.append(button)
        }
        
        updateButtonSelectionStates()
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in urgenceIcons.enumerated() {
            // If the index of a button is less than the rating, that button should be selected.
            button.isSelected = index < rating
            
        }
    }
    //change la couleur des boutons en fonction du rating
    private func updateColor(){
        let bundle = Bundle(for: type(of: self))
        let greenIcon = UIImage(named: "green", in: bundle, compatibleWith: self.traitCollection)
        let orangeIcon = UIImage(named:"orange", in: bundle, compatibleWith: self.traitCollection)
        let redIcon = UIImage(named:"red", in: bundle, compatibleWith: self.traitCollection)
        let grayIcon = UIImage(named:"gray", in: bundle, compatibleWith: self.traitCollection)
        for button in urgenceIcons{
            if(rating==0){
                button.setImage(grayIcon, for: .normal)
                button.setImage(grayIcon, for: .selected)
                button.setImage(grayIcon, for: .highlighted)
                button.setImage(grayIcon, for: [.highlighted, .selected])
            }else if(rating == 1){
                button.setImage(grayIcon, for: .normal)
                button.setImage(greenIcon, for: .selected)
                button.setImage(greenIcon, for: .highlighted)
                button.setImage(greenIcon, for: [.highlighted, .selected])
            }else if(rating==2){
                button.setImage(grayIcon, for: .normal)
                button.setImage(orangeIcon, for: .selected)
                button.setImage(orangeIcon, for: .highlighted)
                button.setImage(orangeIcon, for: [.highlighted, .selected])
            }else if(rating==3){
                button.setImage(grayIcon, for: .normal)
                button.setImage(redIcon, for: .selected)
                button.setImage(redIcon, for: .highlighted)
                button.setImage(redIcon, for: [.highlighted, .selected])
            }else{
                fatalError("Le rating n'existe pas")
            }
        }
    }
}
