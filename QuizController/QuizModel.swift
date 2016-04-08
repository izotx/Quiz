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
    case kSave = "https://izotx.com/igerm/addquiz.php"
    case kJSON = "https://izotx.com/igerm/nursing.json"
}


class NetworkingModel{
    
    //Save question
    static func quizAnswerRequest(qid:Int,aid:Int,correct:Int, user:String){
        let request = NSMutableURLRequest(URL: NSURL(string: URLS.kSave.rawValue)!)
        request.HTTPMethod = "POST"
        let postString = "qid=\(qid)&user=\(user)&aid=\(aid)&correct=\(correct)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let task = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            print(data)
            print(response)
            print(error)
            
            let string =  NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(string)
            
            
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
                    print(error.debugDescription)
                    completetion(nil, error: error.debugDescription)
                }
                else{
                    // create an NSArray with the JSON response data
                    // var jsonReadError:NSError?
                    do {
                        let jsonArray =  try  NSJSONSerialization.JSONObjectWithData(taskData!, options: .AllowFragments)
                        completetion(jsonArray as? [String : AnyObject], error: nil)
                    }
                    catch let error as NSError{
                        print(error);
                        completetion(nil, error: error.debugDescription)
                    }
                    
                }
                
        }).resume()
    }
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
    internal var answers = [Int:Int]() //Question id answer
    private var userId:String
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    init(){
        answers = [Int:Int]()
        userId = QuizModel.getUserUDID()
        //get answers
        getUserAnswers(userId)
    }
    
    
    func getUserAnswers(user:String)->[Int:Int]?{
        
        if let data = defaults.objectForKey(Stats.kAnswersKey.rawValue)  as? NSData,  dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Int:Int] {
            answers = dict
            return dict
        }
        return nil
    }
    
    static func clearAll(){
        let bid =  NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(bid!)
        let d = UIApplication.sharedApplication().delegate as! AppDelegate
        d.quizModel.answers.removeAll()
        QuizModel.getUserUDID()
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
        
        let newId =  UIDevice.currentDevice().identifierForVendor!.UUIDString
        userDefaults.setObject(newId, forKey: OtherDefaultsKeys.kIDKey.rawValue)
        
        return newId
    }
    
    
    convenience init(json:[String:AnyObject]){
        self.init()
        if let questionsArray  = json[QuizQuestions.kQuestionsArray.rawValue] as?  [NSDictionary] {
            for questionObject in questionsArray{
                let quizQuestion = QuizQuestion()
                //  print(questionObject)
                
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
    
    //Check if answer is correct
    func isCorrect(questionId:Int,aid:Int)->Bool{
        getQuestionById(questionId)
        let question = getQuestionById(questionId)
        if let question = question{
            if question.correctAnswerIndex == aid{
                print("correct")
                return true
            }
            
        }
        print("false")
        return false
        
    }
    
    func updateStats(questionId:Int, correctAnswer:Bool){
        
        //Checks the values ssaved to defaults
        var correct = defaults.integerForKey(Stats.kCorrectKey.rawValue)
        var wrong = defaults.integerForKey(Stats.kWrongKey.rawValue)
        var total = defaults.integerForKey(Stats.kAttemptsKey.rawValue)
        total = total + 1
        
        if correctAnswer {
            correct = correct + 1
        }
        else{
            wrong = wrong + 1
        }
        
        
        
        //Save updated stats
        defaults.setInteger(correct, forKey: Stats.kCorrectKey.rawValue)
        defaults.setInteger(wrong, forKey: Stats.kWrongKey.rawValue)
        defaults.setInteger(total, forKey: Stats.kAttemptsKey.rawValue)
        
        defaults.synchronize()
        
    }
    
    static  func getStats()->(correct:Int, wrong:Int,attempts:Int,score:Double){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let correct = defaults.integerForKey(Stats.kCorrectKey.rawValue)
        let wrong = defaults.integerForKey(Stats.kWrongKey.rawValue)
        let attempts = defaults.integerForKey(Stats.kAttemptsKey.rawValue)
        var score = 0.0
        
        if attempts != 0 {
            score =  Double(correct) / Double(attempts) * 100.0
            score = round(10 * score)/10
        }
        
        
        return (correct, wrong, attempts,score)
    }
    
    
    //It will be stored in array of index of question not just increment
    func selectAnswer(question:Int, answer:Int){
        if let _ = getQuestionById(question){
            answers[question] = answer
            saveAnswers(QuizModel.getUserUDID())
            updateStats(question, correctAnswer: isCorrect(question, aid: answer))
            
        }
        else{
            print("ERROR question doesn't exist??")
        }
    }
    
    func getUnansweredQuestions()->[QuizQuestion]{
        
        //get all questions
        var unansweredQuizQuestions = [QuizQuestion]()
        let answers = getUserAnswers(QuizModel.getUserUDID())
        
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
        
        print("Answer \(answer)")
        
        if let answer = answers[questionIndex]{
            sendAnswer(questionIndex, answer:answer)
            print("Answers \(answers)")
            
            return getFeedback(questionIndex, answer: answer)
            
        }
        return "Please select your answer!"
    }
    
    //Confirmed Answer
    func sendAnswer(questionId:Int, answer:Int){
        if let question =   getQuestionById(questionId)
        {
            //Convert bool to int
            var correct = 0
            if answer == question.correctAnswerIndex
            {
                correct = 1
            }
            
            
            //Send information about quiz to the web service
            NetworkingModel.quizAnswerRequest(questionId, aid: answer, correct: correct, user: QuizModel.getUserUDID())
        }
        
    }
    
    //Returns answer selected for given index
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

