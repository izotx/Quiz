//
//  QuizModel.swift
//  QuizController
//
//  Created by Janusz Chudzynski on 8/31/15.
//  Copyright (c) 2015 Janusz Chudzynski. All rights reserved.
//

import UIKit

class QuizQuestion{
    var question:String = ""
    var answers = [String]()
    var feedbacks = [String]()
    var correctAnswerIndex  = -1
}


enum QuizQuestions:String{
    case kQuestionsArray = "questions"
    case kQuestionText = "question"
    case kAnswersArray = "answers"
    case kCorrectIndex = "correctAnswerIndex"
    case kfeedbackArray = "feedback"
}


class NetworkingModel{
    func downloadFile(completetion:([String:AnyObject]?, error:NSString?)->Void){
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        // make a network request for a URL, in this case our endpoint
        session.dataTaskWithURL(NSURL(string: "http://localhost:8888/JSON/nursing.json")!,
            completionHandler: { (taskData, taskResponse, taskError) -> Void in
                
                if let error = taskError
                {
                    println(error.debugDescription)
                    completetion(nil, error: error.debugDescription)
                }
                else{
                    // create an NSArray with the JSON response data
                    var jsonReadError:NSError?
                    
                    let jsonArray = NSJSONSerialization.JSONObjectWithData(
                        taskData, options: nil, error: &jsonReadError) as! [String :AnyObject]
                    if let error = jsonReadError
                    {
                        println(error.debugDescription)
                        completetion(nil, error: error.debugDescription)
                    }
                    else{
                        completetion(jsonArray, error: nil)
                        
                    }
                    
                }
                
        }).resume()
    }
    
    
}


class QuizModel{
    var score:Double = 0.0
    var currentQuestionIndex = 0
    private var quizQuestions = [QuizQuestion]()
    private var answers = [Int:Int]()
    private var correctCount:Int = 0
    private var wrongCount:Int = 0
    
    init(){
        correctCount = 0
        wrongCount = 0
        answers = [Int:Int]()
    }
    
    
    
    
    convenience init(json:[String:AnyObject]){
        self.init()
        if let questionsArray  = json[QuizQuestions.kQuestionsArray.rawValue] as?  [NSDictionary] {
            for questionObject in questionsArray{
                let quizQuestion = QuizQuestion()
                
                if let questionText = questionObject[QuizQuestions.kQuestionText.rawValue] as? String{
                    quizQuestion.question = questionText
                    
                }
                
                if let feedbackArray = questionObject[QuizQuestions.kfeedbackArray.rawValue] as? [String]
                {
                    quizQuestion.feedbacks = feedbackArray
                }
                if let questionsArray = questionObject[QuizQuestions.kAnswersArray.rawValue] as? [String]
                {
                    quizQuestion.answers = questionsArray
                    
                }
                
                addQuestion(quizQuestion)
            }
        }
    }
    
    func addQuestion(q:QuizQuestion){
        quizQuestions.append(q)
    }
    
    func removeQuestion(q:QuizQuestion){
        
    }
    
    func getAllQuestions()->[QuizQuestion]{
        return self.quizQuestions
    }
    
    
    func removeAll()
    {
        quizQuestions.removeAll(keepCapacity: false)
    }
    
    func getQuestion(question:Int)->QuizQuestion?{
        
        if  question < quizQuestions.count{
            return quizQuestions[question]
        }
        return nil
    }
    
    //Validates question's indexes
    func isValid(question:Int, answer:Int)->Bool{
        
        if question < quizQuestions.count{
            let quizQuestion = quizQuestions[question]
            if answer < quizQuestion.answers.count
            {
                return true
            }
        }
        return false
    }
    
    
    func updateStats(question:Int, answer:Int){
        if isValid(question, answer: answer)
        {
            if quizQuestions[question].correctAnswerIndex == answer{
                correctCount = correctCount + 1
            }
            else{
                wrongCount = wrongCount + 1
            }
        }
    }
    
    func getStats()->(correct:Int, wrong:Int,score:Double){
        
        return (correctCount, wrongCount, (Double(correctCount) / Double((correctCount+wrongCount))))
    }
    
    
    func selectAnswer(question:Int, answer:Int){
        if isValid(question, answer: answer)
        {
            answers[question] = answer
            updateStats(question, answer: answer)
        }
    }
    
    
    func getFeedback(question:Int, answer:Int)->String{
        if isValid(question, answer: answer)
        {
            return quizQuestions[question].answers[answer]
        }
        return "Wrong Index"
    }
}

