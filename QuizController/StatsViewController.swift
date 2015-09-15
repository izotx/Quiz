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
    @IBOutlet weak var remaingQuestionsLabel: UILabel!
    @IBOutlet weak var generalFeedback: UILabel!
    
    var quizModel:QuizModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = UIModalPresentationStyle.FullScreen
        modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        percantegeLabel.text = "\(QuizModel.getStats().score)%"
        wrongAnswersLabel.text = "\(QuizModel.getStats().wrong)"
        correctAnswersLabel.text = "\(QuizModel.getStats().correct)"
        totalAnswersLabel.text = "\(QuizModel.getStats().attempts)"
        userUUIDNumber.text = "\(QuizModel.getUserUDID())"
       if let qm = self.quizModel
       {
        var remainingQuestionCount = qm.getUnansweredQuestions().count
        remaingQuestionsLabel.text = "\(remainingQuestionCount)"
        
        if(remainingQuestionCount == 0){
            generalFeedback.text = "Great job! Thank you for answering all questions!"
        }
        else{
            generalFeedback.text = "Tap on the quiz button to get back to quiz question."
        }
      }
    }
    
    
    @IBAction func quizAction(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        
    }
    
    
    
}
