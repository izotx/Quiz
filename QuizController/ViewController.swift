//
//  ViewController.swift
//  QuizController
//
//  Created by Janusz Chudzynski on 8/31/15.
//  Copyright (c) 2015 Janusz Chudzynski. All rights reserved.
//

import UIKit


class QuizCell:UITableViewCell{
    static let identifier = "kQuizCell"
    @IBOutlet weak var answerLabel: UILabel!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
            
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    }

}

class ViewController: UIViewController,UITableViewDelegate {
    @IBOutlet weak var questionConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var feedbackConstraintHeight: NSLayoutConstraint!

    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var helpView: UIView?
    
    @IBOutlet weak var nextQuestionButton: UIBarButtonItem!
    @IBOutlet weak var previousQuestionButton: UIBarButtonItem!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
//    var helpView = UIView(frame: view.bounds)
    
    var dataSource: DataSource?
    var quizModel: QuizModel?
    var networkingModel = NetworkingModel()
    var currentQuestion:QuizQuestion?
    
    
    @IBAction func confirmAnswerAction(sender: AnyObject) {
       
        if let quizModel = quizModel, qid = currentQuestion?.qid {
             self.feedbackTextView.alpha = 0
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.feedbackTextView.alpha = 1
            }, completion: { (completed) -> Void in
                self.updateTableContent(quizModel.currentQuestionArrayIndex)
                self.feedbackTextView.text = quizModel.confirmAnswerAndGetFeedback(qid) as String
            })
        }
    }

      
    
    func updateTableContent(index:Int){
        if let quizModel = quizModel {
            //set index of question
            quizModel.currentQuestionArrayIndex = index
            currentQuestion = quizModel.getAllQuestions()[index]

            //update toolbar 
            if quizModel.firstQuestion(){
                previousQuestionButton.enabled = false
            }
            else{
                previousQuestionButton.enabled = true
            }
            if quizModel.lastQuestion(){
                nextQuestionButton.enabled = false
            }
            else{
              nextQuestionButton.enabled = true
            }
            
            if !quizModel.questionAnswered(currentQuestion!.qid!)
            {
                 previousQuestionButton.enabled = false
                  nextQuestionButton.enabled = false
            }
            
            
            
            let question = quizModel.getAllQuestions()[index]
            questionTextView.text = question.question
            
            self.feedbackTextView.text = ""
            
        self.dataSource = DataSource(items: quizModel.getAllQuestions()[self.quizModel!.currentQuestionArrayIndex].answers, identifier: QuizCell.identifier, cellhandler: { (cell, item, indexPath) -> Void in
            
            if let c = cell as? QuizCell, let item = item as? String, qid = self.currentQuestion?.qid{
                c.answerLabel.text = item;
                c.accessoryType = UITableViewCellAccessoryType.None
               
                if quizModel.isSelected(qid, answer: indexPath.row)
                {
                  c.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
            }
        })

        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
        self.tableView.reloadData()
        
        }
    }
    
    
   
    

    @IBAction func previousQuestionAction(sender: AnyObject) {
        if let model = quizModel{
            model.previousQuestion()
            updateTableContent(model.currentQuestionArrayIndex)
        }
    }
    
    @IBAction func nextQuestionAction(sender: AnyObject) {
        if let model = quizModel{
            model.nextQuestion()
            updateTableContent(model.currentQuestionArrayIndex)
        }
    
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let quizModel = self.quizModel, qid = currentQuestion?.qid{
           
            quizModel.selectAnswer(qid, answer: indexPath.row)
            self.feedbackTextView.text = ""
            self.tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100.0
        self.navigationController?.navigationBarHidden = true
        
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
       
        NetworkingModel.downloadFile { (dict:[String : AnyObject]?, error) -> Void in
            //println("Downloaded! woot woot \(dict)")
            if let dict = dict {
                
                self.quizModel = QuizModel(json: dict)
                
                // self.tableView.registerClass(QuizCell.self, forCellReuseIdentifier: QuizCell.identifier)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updateTableContent(0)
                })
                
            }
            
            if let error = error {
                //display error
            }
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
          }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

