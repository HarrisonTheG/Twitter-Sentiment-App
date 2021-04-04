//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON


class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    
    let tweetCount = 100
    let sentimentClassifier = TweetSentimentClassifier()
    
    //access API keys from plist (unhandled)
    let swifter = Swifter(consumerKey:fetchApiKey(value: "api")!, consumerSecret:fetchApiKey(value: "secret")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    @IBAction func predictPressed(_ sender: Any) {
 
         fetchTweets()
    
    }
    
    func fetchTweets(){
        
        
        if let searchText = textField.text {
          swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
              
              var tweets = [TweetSentimentClassifierInput]()
              
             for i in 0..<self.tweetCount {
              if let tweet = results[i]["full_text"].string {
                  let tweetInput = TweetSentimentClassifierInput(text: tweet)
                  tweets.append(tweetInput)}
                  }
            let score = self.makePrediction(with: tweets)
            self.updateUI(with: score)
          }
              
          ) { (error) in
              print ("there was an error witht the Twitter API request \(error)")
              }}
    }
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) -> Int{
        var predictionScore = 0
        do{
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            for pred in predictions{
                if pred.label == "Pos"{
                predictionScore += 1
                } else if pred.label == "Neg" {
                    predictionScore -= 1
                }
            }
            
        }
        catch {
            print("Unable to make predictions, \(error)")
        }
        return predictionScore
    }
    func updateUI(with predictionScore: Int){
        
        if predictionScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if predictionScore > 10 {
            self.sentimentLabel.text = "😀"
        } else if predictionScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if predictionScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if predictionScore > -10 {
            self.sentimentLabel.text = "😕"
        } else if predictionScore > -20 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
    }
}

//newly added 4/4/2021

func fetchApiKey (value: String) -> String?{
    
    
    guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
    fatalError("Couldn't find file 'Secrets.plist'.")
    }
    
    guard let xml = FileManager.default.contents(atPath: filePath) else {
        fatalError("Couldn't get data with Data data type from path.")
    }
    if let apiKeys = try? PropertyListDecoder().decode(ApiKeys.self, from: xml) {
        if (value == "secret")
        {return apiKeys.apiSecretKey}
        else
        {return apiKeys.apiKey}
    }
    return nil
}



