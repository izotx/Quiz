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
    required init?(coder aDecoder: NSCoder) {
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
    
    var dataSource: DataSource?
    var delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var quizModel: QuizModel!
    
    var networkingModel = NetworkingModel()
    var currentQuestion:QuizQuestion?
    var tempAnswerIndex:Int?
    
    
    @IBAction func goBackToHandHygieneAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    
    
    @IBAction func confirmAnswerAction(sender: AnyObject) {
        
        if let quizModel = quizModel, qid = currentQuestion?.qid, answer = tempAnswerIndex {
            
            
            self.feedbackTextView.alpha = 0
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.feedbackTextView.alpha = 1
                }, completion: { (completed) -> Void in
                    
                    self.updateTableContent(quizModel.currentQuestionArrayIndex)
                    self.feedbackTextView.text = quizModel.confirmAnswerAndGetFeedback(qid, answer:answer) as String
                    
                    self.delay(0.5, closure: { () -> () in
                        self.showStats()
                    })
            })
        }
        else{
            self.feedbackTextView.alpha = 0
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.feedbackTextView.alpha = 1
                }, completion: { (completed) -> Void in
                    self.feedbackTextView.text = "Please select your answer first"
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if quizModel.currentQuestionArrayIndex < quizModel.getAllQuestions().count{
            self.updateTableContent(quizModel.currentQuestionArrayIndex)
        }
        
        
    }
    
    
    
    func updateToolbar(){
        //update toolbar
        if let quizModel = quizModel {
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
        }
    }
    
    
    func updateTableContent(index:Int){
        
        
        if let quizModel = quizModel {
            //set index of question
            quizModel.currentQuestionArrayIndex = index
            currentQuestion = quizModel.getAllQuestions()[index]
            //Update toolbar
            updateToolbar()
            
            //Update UI
            questionTextView.text = currentQuestion!.question
            self.feedbackTextView.text = ""
            self.tableView.userInteractionEnabled = true
            self.doneButton.enabled = true
            
            
            if let qid  = currentQuestion?.qid, aid = quizModel.getAnswer(qid){
                if quizModel.isSelected(qid, answer: aid){
                    if quizModel.isCorrect(qid, aid: aid)
                    {
                        self.tableView.userInteractionEnabled = false
                        feedbackTextView.text = quizModel.getFeedback(qid, answer: aid)
                        self.doneButton.enabled = false
                    }
                }
            }
            
            //Settinp the datasource for the
            self.dataSource = DataSource(items: quizModel.getAllQuestions()[self.quizModel!.currentQuestionArrayIndex].answers, identifier: QuizCell.identifier, cellhandler: { (cell, item, indexPath) -> Void in
                
                if let c = cell as? QuizCell, let item = item as? String, qid = self.currentQuestion?.qid{
                    c.answerLabel.text = item;
                    c.accessoryType = UITableViewCellAccessoryType.None
                    c.tintColor = UIColor.darkGrayColor()
                    
                    if let tempAnswer = self.tempAnswerIndex{//user selected answer
                        
                        if indexPath.row == tempAnswer
                        {
                            c.accessoryType = UITableViewCellAccessoryType.Checkmark
                        }
                        
                    }
                    else{
                        if quizModel.isSelected(qid, answer: indexPath.row){
                            c.accessoryType = UITableViewCellAccessoryType.Checkmark
                            
                            if quizModel.isCorrect(qid, aid: indexPath.row)
                            {
                                c.tintColor = UIColor.greenColor()
                                
                            }
                        }
                    }
                    
                    if quizModel.isSelected(qid, answer: indexPath.row) && self.tempAnswerIndex == nil {
                        c.accessoryType = UITableViewCellAccessoryType.Checkmark
                        if quizModel.isCorrect(qid, aid: indexPath.row)
                        {
                            c.tintColor = UIColor.greenColor()
                            
                        }
                    }
                    
                    if quizModel.isSelected(qid, answer: indexPath.row) && self.tempAnswerIndex != nil && self.tempAnswerIndex == indexPath.row{
                        c.accessoryType = UITableViewCellAccessoryType.Checkmark
                        if quizModel.isCorrect(qid, aid: indexPath.row)
                        {
                            c.tintColor = UIColor.greenColor()
                            
                        }
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
            tempAnswerIndex = nil
            model.previousQuestion()
            updateTableContent(model.currentQuestionArrayIndex)
        }
    }
    
    @IBAction func nextQuestionAction(sender: AnyObject) {
        if let model = quizModel{
            tempAnswerIndex = nil
            model.nextQuestion()
            updateTableContent(model.currentQuestionArrayIndex)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if let _ = self.quizModel, _ = currentQuestion?.qid{
            //Sets temporary selection that will be used to determine if the answer is selected or not
            tempAnswerIndex = indexPath.row
            self.feedbackTextView.text = ""
            //Correct answer is checked when the table is reloaded
            self.tableView.reloadData()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100.0
        self.navigationController?.navigationBarHidden = true
        self.quizModel =  delegate.quizModel
        prepareQuizContent()
        
    }
    
    
    func prepareQuizContent(){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        networkingModel.downloadFile { (dict:[String : AnyObject]?, error) -> Void in
            if let dict = dict {
                
                self.quizModel = QuizModel(json: dict)
                self.delegate.quizModel = self.quizModel
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let quizq = self.quizModel?.getUnansweredQuestions()
                    //get all
                    if quizq?.count > 0 {
                        let qf =  quizq!.first//take first from unanswered questions
                        
                        var index  = 0
                        if let _ = self.quizModel{
                            for q in self.quizModel!.getAllQuestions()
                            {
                                if  qf?.qid == q.qid
                                {
                                    self.updateTableContent(index)
                                    break
                                }
                                index++
                            }
                        }
                    }
                    else{
                        if self.quizModel?.getAllQuestions().count > 0{
                            self.updateTableContent(0)
                        }
                        self.showStats()
                    }
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    }
                )
            }
            
            if let _ = error {
                //display error
                dispatch_async(dispatch_get_main_queue(), {
                    self.feedbackTextView.text = "Error. Please try again later."
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
            }
            
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showStats(){
        self.performSegueWithIdentifier("showStatsSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showStatsSegue"{
            if let _ = segue.destinationViewController as? StatsViewController{
                let vc = segue.destinationViewController as! StatsViewController
                vc.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                vc.quizModel = quizModel
            }
            
        }
    }
    
}

