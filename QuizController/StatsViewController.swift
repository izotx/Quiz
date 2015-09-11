//
//  StatsViewController.swift
//  QuizController
//
//  Created by Janusz Chudzynski on 9/11/15.
//  Copyright (c) 2015 Janusz Chudzynski. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {
    
    @IBOutlet weak var userUUIDNumber: UILabel!
    @IBOutlet weak var percantegeLabel: UILabel!
    @IBOutlet weak var wrongAnswersLabel: UILabel!
    @IBOutlet weak var correctAnswersLabel: UILabel!
    @IBOutlet weak var totalAnswersLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        percantegeLabel.text = "\(QuizModel.getStats().score)"
        wrongAnswersLabel.text = "\(QuizModel.getStats().wrong)"
        correctAnswersLabel.text = "\(QuizModel.getStats().correct)"
        totalAnswersLabel.text = "\(QuizModel.getStats().attempts)"
        userUUIDNumber.text = "\(QuizModel.getUserUDID())"
    
    }
    
    
    @IBAction func quizAction(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    
}
