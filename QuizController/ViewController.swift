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
    
    var dataSource: DataSource?
    var quizModel: QuizModel?
    var networkingModel = NetworkingModel()
    
    
    func updateTableContent(index:Int){
        if let quizModel = quizModel {
        let question = self.quizModel!.getAllQuestions()[index]
            questionTextView.text = question.question
            
            self.feedbackTextView.text = ""
            
        self.dataSource = DataSource(items: self.quizModel!.getAllQuestions()[self.quizModel!.currentQuestionIndex].answers, identifier: QuizCell.identifier, cellhandler: { (cell, item) -> Void in
            
            if let c = cell as? QuizCell, let item = item as? String{
                c.answerLabel.text = item;
            }
            
        })
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
        self.tableView.reloadData()
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let quizModel = self.quizModel{
            quizModel.selectAnswer(quizModel.currentQuestionIndex, answer: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100.0
        
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        networkingModel.downloadFile { (dict:[String : AnyObject]?, error) -> Void in
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

