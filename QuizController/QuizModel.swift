//
//  QuizModel.swift
//  QuizController
//
//  Created by Janusz Chudzynski on 8/31/15.
//  Copyright (c) 2015 Janusz Chudzynski. All rights reserved.
//

import UIKit



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

enum URLS:String{
    case kSave = "http://izotx.com/igerm/addquiz.php"
    case kJSON = "http://izotx.com/igerm/nursing.json"
}


class NetworkingModel{
    
    //Save question
    static func quizAnswerRequest(qid:Int,aid:Int,correct:Int, user:String){
        let request = NSMutableURLRequest(URL: NSURL(string: URLS.kSave.rawValue)!)
        request.HTTPMethod = "POST"
        let postString = "qid=\(qid)&user=\(user)&aid=\(aid)&correct=\(correct)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let task = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            println(data)
            println(response)
            println(error)
            
            let string =  NSString(data: data, encoding: NSUTF8StringEncoding)
            println(string)
            
            
        })
        task.resume()
    }
    
    //Get JSON File
    func downloadFile(completetion:([String:AnyObject]?, error:NSString?)->Void){
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        // make a network request for a URL, in this case our endpoint
        session.dataTaskWithURL(NSURL(string: URLS.kJSON.rawValue)!,
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
                        println(error.debugDescription)
                        completetion(nil, error: error.debugDescription)
                    }
                    else{
                        completetion(jsonArray, error: nil)
                        
                    }
                    
                }
                
        }).resume()
    }
    
    //
    
    
    
    
}



enum Stats:String{
    case kWrongKey = "Wrong"
    case kCorrectKey = "Correct"
    case kAttemptsKey = "Attempts"
    case kAnswersKey = "Answers"
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
    private var userId:String
    
    private var defaults = NSUserDefaults.standardUserDefaults()
//    private var userId =
    init(){
        correctCount = 0
        wrongCount = 0
        answers = [Int:Int]()
        userId = QuizModel.getUserUDID()
        //get answers
        getUserAnswers(userId)
    }
    
    
    func getUserAnswers(user:String)->[Int:Int]?{

        if let data = defaults.objectForKey(Stats.kAnswersKey.rawValue)  as? NSData,     dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Int:Int] {
            answers = dict
            return dict
        }
        return nil
    }
    
    func saveAnswers(user:String){
      let data =  NSKeyedArchiver.archivedDataWithRootObject(answers)
      userDefaults.setObject(data, forKey: Stats.kAnswersKey.rawValue)
      defaults.synchronize()
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
    
    
    func isCorrect(questionId:Int,aid:Int)->Bool{
        let filtered  = self.quizQuestions.filter({$0.qid == questionId})
        if let question = filtered.last{
            if question.correctAnswerIndex == aid{
                return true
            }
            
        }
        return false
    
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
          score =  Double(correct) / Double(attempts) * 100.0
          score = round(10 * score)/10
        }
        
        
        return (correct, wrong, attempts,score)
    }

        
    //It might be initially selected answer
    func selectAnswer(question:Int, answer:Int){
        if let q = getQuestionById(question){
           answers[question] = answer
        
        }
    }
 
    func getUnansweredQuestions()->[QuizQuestion]{

        //get all questions
        var unansweredQuizQuestions = [QuizQuestion]()
        var answers = getUserAnswers(QuizModel.getUserUDID())
    
        if let answers = answers{
            for q in getAllQuestions()
            {
                if let qid = q.qid
                {
                    if let aid = answers[qid]{
                        if !isCorrect(qid, aid: aid){
                            unansweredQuizQuestions.append(q)
                        }
                    }else{
                        unansweredQuizQuestions.append(q)
                       
                    }
                }
        }
    }
        else{
            return getAllQuestions()
    }
    
    

        return unansweredQuizQuestions
    }
    
    func confirmAnswerAndGetFeedback(questionIndex:Int, answer:Int)->NSString{
        
        //select answer
        selectAnswer(questionIndex, answer: answer)
        
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
            
            
            //Convert bool to int
            var correct = 0
            if answer == question.correctAnswerIndex
            {
              correct = 1
            }
            saveAnswers(QuizModel.getUserUDID())
            NetworkingModel.quizAnswerRequest(questionId, aid: answer, correct: correct, user: QuizModel.getUserUDID())
        }
    }
    
    func getAnswer(qid:Int)->Int?{
        return answers[qid]
    }
    
    
    func isSelected(question:Int,answer:Int)-> Bool{
     
            return answers[question] == answer
    }
    
    func getFeedback(question:Int, answer:Int)->String{
        
        if let q = getQuestionById(question){
            return q.feedbacks[answer]
        }

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

