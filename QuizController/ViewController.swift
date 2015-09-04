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
}

class ViewController: UIViewController {
    @IBOutlet weak var questionConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var feedbackConstraintHeight: NSLayoutConstraint!

    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: DataSource?
    var quizModel: QuizModel?
    var networkingModel = NetworkingModel()
    
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
                self.tableView.registerClass(QuizCell.self, forCellReuseIdentifier: QuizCell.identifier)
                
                self.dataSource = DataSource(items: self.quizModel!.getAllQuestions(), identifier: QuizCell.identifier, cellhandler: { (cell, item) -> Void in
                    println("Items \(item)")
                    if let c = cell as? QuizCell, let item = item as? QuizQuestion{
                        
                        
                    }
                    
                })
                self.tableView.dataSource = self.dataSource
                
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

