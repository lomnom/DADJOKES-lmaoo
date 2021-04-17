//
//  ViewController.swift
//  DAD
//
//  Created by Nyein Nyein on 10/4/21.
//

import UIKit
import Foundation
extension String {
    func components<T>(separatedBy separators: [T]) -> [String] where T : StringProtocol {
        var result = [self]
        for separator in separators {
            result = result
                .map { $0.components(separatedBy: separator)}
                .flatMap { $0 }
        }
        return result
    }
}

func write(data: String, file: String){
    print("wrote \(data) to \(file)")
    
    let text = data //just a text

    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

        let fileURL = dir.appendingPathComponent(file)

        //writing
        do {
            try text.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */}

    }
}

func read(file: String) -> String{
    var text=""
    
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

        let fileURL = dir.appendingPathComponent(file)

        //reading
        do {
            text = try String(contentsOf: fileURL, encoding: .utf8)
        }
        catch {/* error handling here */}
    }
    print("read \(text) from \(file)")
    return text
}

func readJoke() -> Array<String>{
    return read(file: "JOKE.txt").split{$0 == "\n"}.map(String.init)
}

func getNextJoke(){
    var parts=[""]
    
    var request = URLRequest(url: URL(string: "https://icanhazdadjoke.com")!)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
        do{
            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
            
            let joke=json["joke"]?.replacingOccurrences(of: "?\n", with: "? ").replacingOccurrences(of: "!\n", with: "! ").replacingOccurrences(of: ".\n", with: ". ").replacingOccurrences(of: "\n", with: "")
            
            if joke!.replacingOccurrences(of: " ", with: " ").components(separatedBy: ["\" ",". ","! ","? "]).count > 2{
                parts[0]=joke!
            }else{
                parts=joke!.replacingOccurrences(of: "? ", with: "Ξ? ").replacingOccurrences(of: "! ", with: "Ϡ! ").replacingOccurrences(of: "\" ", with: "ϫ\" ").replacingOccurrences(of: ". ", with: "ύ. ").components(separatedBy: ["\" ",". ","! ","? "])
                
                parts[0]=parts[0].replacingOccurrences(of: "Ξ", with: "?")
                parts[0]=parts[0].replacingOccurrences(of: "Ϡ", with: "!")
                parts[0]=parts[0].replacingOccurrences(of: "ύ", with: ".")
                parts[0]=parts[0].replacingOccurrences(of: "ϫ", with: "\"")
                
                if parts.count==2{
                    parts[1]=parts[1].replacingOccurrences(of: "Ξ", with: "?")
                    parts[1]=parts[1].replacingOccurrences(of: "ϫ", with: "\"")
                    parts[1]=parts[1].replacingOccurrences(of: "ύ", with: ".")
                    parts[1]=parts[1].replacingOccurrences(of: "Ϡ", with: "!")
                }
            }
            
            let nextJoke=parts.joined(separator: "\n")
            
            print("got joke \(nextJoke)")
            
            write(data: nextJoke,file: "JOKE.txt")
        } catch {
            print(error)
        }
    })
    
    task.resume()
}

class ViewController: UIViewController {
    
    @IBOutlet weak var A: UILabel!
    @IBOutlet weak var Q: UILabel!
    @IBOutlet weak var SINGLELINE: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        write(data: "PUNCHLINE", file:"STATE.txt")
        A.adjustsFontSizeToFitWidth = true
        A.minimumScaleFactor = 0.2
        Q.adjustsFontSizeToFitWidth = true
        Q.minimumScaleFactor = 0.2
        SINGLELINE.adjustsFontSizeToFitWidth = true
        SINGLELINE.minimumScaleFactor = 0.2
        // Do any additional setup after loading the view.
        getNextJoke()
        self.A.alpha = 0
    }
    
    @IBAction func NEW(_ sender: Any) {
        if read(file: "STATE.txt")=="PUNCHLINE"{
            print("\n showing joke and loading new joke")
            let parts=readJoke()
            if parts.count==1{ //show joke
                self.SINGLELINE.text=parts[0].replacingOccurrences(of: "", with: "\n")
                self.A.text=""
                self.Q.text=""
                self.A.alpha = 0
                write(data: "PUNCHLINE", file:"STATE.txt")
            }else{
                self.SINGLELINE.text=""
                self.Q.text=parts[0].replacingOccurrences(of: "", with: "\n")
                self.A.alpha = 0
                write(data: "JOKE", file:"STATE.txt")
                write(data: parts[1], file: "PUNCHLINE.txt")
            }
            getNextJoke()
        }else{ //show punchline
            print("\n showing punchline")
            let punch=read(file: "PUNCHLINE.txt")
            self.A.text=punch.replacingOccurrences(of: "", with: "\n")
            UIView.animate(withDuration: 1){
                self.A.alpha = 1
            }
            write(data: "PUNCHLINE", file:"STATE.txt")
        }
    }
}
