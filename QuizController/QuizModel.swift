//
//  QuizModel.swift
//  QuizController
//
//  Created by Janusz Chudzynski on 8/31/15.
//  Copyright (c) 2015 Janusz Chudzynski. All rights reserved.
//

import UIKit
import Alamofire

enum URLS:String{
    case kJSONQuiz = "http://localhost:8888/JSON/nursing1.json"
    case kAnswers = "http://izotx.com/igerm/addquiz.php"
}


class QuizQuestion{
    var qid:Int?
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
    case kQuestionIndex = "qid"
}


class NetworkingModel{
    
    //Get JSON File
   static func downloadFile(completetion:([String:AnyObject]?, error:NSString?)->Void){
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        // make a network request for a URL, in this case our endpoint
        session.dataTaskWithURL(NSURL(string: URLS.kJSONQuiz.rawValue)!,
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
                        taskData, options: nil, error: &jsonReadError) as? [String :AnyObject]

                    if let error = jsonReadError
                    {
                       // println(error.debugDescription)
                        completetion(nil, error: error.debugDescription)
                    }
                    else{
                        completetion(jsonArray, error: nil)
                        
                    }
                    
                }
                
        }).resume()
    }
    
    
    static func testURLSession()
    {
        
        Alamofire.request(.POST, URLS.kAnswers.rawValue, parameters: ["foo": "bar"])
            .response { request, response, data, error in
                print(request)
                print(response)
                print(error)
        }
        return
        
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        var usr = "dsdd"
        var pwdCode = "dsds"
        let params:[String: AnyObject] = [
            "email" : usr,
            "userPwd" : pwdCode ]
        
        let url = NSURL(string: URLS.kAnswers.rawValue)
        let request = NSMutableURLRequest(URL: url!)
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.allZeros, error: &err)
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            let str =  NSString(data: data, encoding: NSUTF8StringEncoding)
            println(str)

            
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    println("response was not 200: \(response)")
                    return
                }
            }
            if (error != nil) {
                println("error submitting request: \(error)")
                return
            }
            
            // handle the data of the successful response here
            var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary
            println(result)
        }
        task.resume()
    
    }
    
    
    static func saveAnswer(qid:Int, answerId:Int, userId:String, correct:Bool, completetion:(NSDictionary?, error:NSString?)->Void){
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let request = NSMutableURLRequest(URL: NSURL(string: URLS.kAnswers.rawValue)!)
       //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
       // request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        
        var c = 0
        if correct{
         c = 1
        }
    
        //"qid":qid, "aid":answerId, "correct":c, "user":userId
        var params = ["qid":qid, "aid":answerId, "correct":c, "user":userId ] as Dictionary<String, AnyObject>
        
        var err: NSError?
        let requestBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.allZeros, error: &err)
        if requestBody == nil {
            //error
            println(err?.debugDescription)
        
            return
        }
        
        request.HTTPBody = requestBody
        
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              //  println(error?.debugDescription)
                println(request)
                println(data)
              // println(response)
              
               let str =  NSString(data: data, encoding: NSUTF8StringEncoding)
               println(str)
                
                
            })

            
            if let error = error
                {
                    
                    completetion(nil, error: error.debugDescription)
                    return

             }
            
             if let data = data{
                    // create an NSArray with the JSON response data
               
                    var jsonReadError:NSError?
                    let jsonArray = NSJSONSerialization.JSONObjectWithData(
                        data, options: NSJSONReadingOptions.AllowFragments, error: &jsonReadError) as? NSDictionary
                
                    println(jsonArray)

                
                    if let error = jsonReadError
                    {
                        
                        completetion(nil, error: error.debugDescription)
                    }
                    else{
                        completetion(jsonArray, error: nil)
                        
                    }
                }
                
        }).resume()
    }

}



enum Stats:String{
    case kWrongKey = "Wrong"
    case kCorrectKey = "Correct"
    case kAttemptsKey = "Attempts"
    
}

enum OtherDefaultsKeys:String{
    case kIDKey = "UniqueKey"
}




class QuizModel{
    var score:Double = 0.0
    var currentQuestionArrayIndex = 0
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private var quizQuestions = [QuizQuestion]()
    private var answers = [Int:Int]() //Question id answer
    private var correctCount:Int = 0
    private var wrongCount:Int = 0
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    init(){
        correctCount = 0
        wrongCount = 0
        answers = [Int:Int]()
        QuizModel.getUserUDID()
    }
    
   static func getUserUDID()->String{
       let userDefaults = NSUserDefaults.standardUserDefaults()
    if let id = userDefaults.stringForKey(OtherDefaultsKeys.kIDKey.rawValue){
        return id
    }
    
    //        case kIDKey = "UniqueKey"
    
    let newId =  UIDevice.currentDevice().identifierForVendor.UUIDString
    userDefaults.setObject(newId, forKey: OtherDefaultsKeys.kIDKey.rawValue)
    
    return newId
   }
    
    
    
    
    convenience init(json:[String:AnyObject]){
        self.init()
        if let questionsArray  = json[QuizQuestions.kQuestionsArray.rawValue] as?  [NSDictionary] {
            for questionObject in questionsArray{
                let quizQuestion = QuizQuestion()
              //  println(questionObject)
                
                if let correctIndex = questionObject[QuizQuestions.kCorrectIndex.rawValue]as? Int{
                    quizQuestion.correctAnswerIndex = correctIndex
                }
                
                if let qid = questionObject[QuizQuestions.kQuestionIndex.rawValue] as? Int{
                     quizQuestion.qid = qid
                }                
                
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
    
    
    func previousQuestion(){
        if currentQuestionArrayIndex > 0 {
            currentQuestionArrayIndex = currentQuestionArrayIndex - 1
        }
    }

    func nextQuestion(){
        if currentQuestionArrayIndex < self.quizQuestions.count - 1  {
            currentQuestionArrayIndex = currentQuestionArrayIndex + 1
        }
    }
    
    func lastQuestion()->Bool{
        return currentQuestionArrayIndex == quizQuestions.count - 1
    }
    
    func firstQuestion()->Bool{
        return currentQuestionArrayIndex == 0
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
    
    
    func questionAnswered(index:Int)->Bool{
    
        return answers[index] != nil
    }
    
    func updateStats(questionId:Int){
        
        correctCount = 0
        wrongCount = 0
        var total = defaults.integerForKey(Stats.kAttemptsKey.rawValue)
        total = total + 1
        

        for answer in answers{
             let filtered  = self.quizQuestions.filter({$0.qid == questionId})
            if let question = filtered.last{
                
                if question.correctAnswerIndex == answer.1
                {
                    correctCount = correctCount + 1
                }
                else{
                    wrongCount = wrongCount + 1
                }
            }
        }
        
        defaults.setInteger(correctCount, forKey: Stats.kCorrectKey.rawValue)
        defaults.setInteger(wrongCount, forKey: Stats.kWrongKey.rawValue)
        defaults.setInteger(total, forKey: Stats.kAttemptsKey.rawValue)

        defaults.synchronize()
        
    }
    
static  func getStats()->(correct:Int, wrong:Int,attempts:Int,score:Double){
    
        let defaults = NSUserDefaults.standardUserDefaults()
        var correct = defaults.integerForKey(Stats.kCorrectKey.rawValue)
        var wrong = defaults.integerForKey(Stats.kWrongKey.rawValue)
        var attempts = defaults.integerForKey(Stats.kAttemptsKey.rawValue)
        var score = 0.0
    
        if attempts != 0 {
          score =  Double(correct / attempts) * 100.0
        }
        
        
        return (correct, wrong, attempts,score)
    }
    
    //It might be initially selected answer
    func selectAnswer(question:Int, answer:Int){
        if let q = getQuestionById(question){
           answers[question] = answer
        
        }
    }
 
    
    
    
    
    func confirmAnswerAndGetFeedback(questionIndex:Int)->NSString{
        
        
        
        if let answer = answers[questionIndex]{
            confirmAnswer(questionIndex, answer:answer)
            return getFeedback(questionIndex, answer: answer)
        
        }
            return "Please select your answer!"
    }
    
    //Confirmed Answer
    func confirmAnswer(questionId:Int, answer:Int){
        let filtered  = self.quizQuestions.filter({$0.qid == questionId})
        if let question = filtered.last{
           
            answers[questionId] = answer
            updateStats(questionId)

        }
    }
    
    func isSelected(question:Int,answer:Int)-> Bool{
            println(answers[question])
            println(answer)
        
        
            return answers[question] == answer
    }
    
    func getFeedback(question:Int, answer:Int)->String{
        
        if let q = getQuestionById(question){
            return q.feedbacks[answer]
        }

        fatalError("wrong Index")
        return "wrong index"
        
    }
    
    func getQuestionById(questionId:Int)->QuizQuestion?{
        let filtered  = self.quizQuestions.filter({$0.qid == questionId})
        if let question = filtered.last{
            return question
        }
        return nil
    }
   
    
}

