import Foundation
import SwiftyJSON

let tagger = NSLinguisticTagger(tagSchemes: [.lemma, .lexicalClass, .nameType, .tokenType, .language], options: 0)
let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]

var partsOfSpeechDict: Dictionary<String, String> = [:]
var lemmatizeDict: Dictionary<String, String> = [:]
var tokenizeDict: Dictionary<String, String> = [:]
var entityRecognitionDict: Dictionary<String, String> = [:]
var indexDict: Dictionary<String,String> = [:]

func traverseDirectory() {
    let documentPath = NSSearchPathForDirectoriesInDomains(.allApplicationsDirectory, .localDomainMask, true)[0]
    let url: URL = URL(fileURLWithPath: documentPath)
    
    let filemanager = FileManager.default
    let enumerator: FileManager.DirectoryEnumerator = filemanager.enumerator(atPath: url.path)!
    while let element = enumerator.nextObject() as? String, element.hasSuffix("txt") {
        //readTextFile(filepath: "")
        //writeToJSONFile(for: <#T##String#>, filename: <#T##String#>, messageDictionary: <#T##Dictionary<String, String>#>)
    }
}
/*
func writeToJSONFile(filepath: String, filename: String, messageDictionary: Dictionary<String, String>) {
    if JSONSerialization.isValidJSONObject(messageDictionary) {
        do {
            let rawData = try JSONSerialization.data(withJSONObject: messageDictionary, options: [.prettyPrinted,.sortedKeys])
            try? rawData.write(to: URL(fileURLWithPath: filepath + "/" + filename), options: .atomicWrite)
        } catch {
            print("Error writing file")
        }
    }
}
*/

//dict1 parameter always takes tokenize dictionary
func writeToJSONFile(filepath: String, filename: String, dict1: [String:String], dict2: [String:String], dict3: [String:String]) {
    var array1 = [[String:String]]()
    dict1.map{array1.append([$0.key:$0.value])}
    
    var array2 = [[String:String]]()
    dict2.map{array2.append([$0.key:$0.value])}
    
    var array3 = [[String:String]]()
    dict3.map{array3.append([$0.key:$0.value])}
    
    var finalArray = [[String:String]]()
    
    for index in 0..<dict1.count {
        var dict = array1[index]
        dict.merge(array2[index]) {$1}
        finalArray.append(dict)
    }
    //print(finalArray)
    let jsonData = try! JSONSerialization.data(withJSONObject: finalArray, options: [JSONSerialization.WritingOptions.prettyPrinted,JSONSerialization.WritingOptions.sortedKeys])
    try? jsonData.write(to: URL(fileURLWithPath: filepath + "/" + filename), options: .atomicWrite)
}

func readTextFile(filepath: String) -> String {
    var text: String = ""
    text = try! String(contentsOf: URL(fileURLWithPath: filepath))
    return text
}

func determineLanguage(text: String) {
    tagger.string = text
    let lang = tagger.dominantLanguage
    print("Dominant languages is \(lang!)")
}

func tokenizeText(text: String) -> Dictionary<String, String> {
    var word_no: Int = 0
    tagger.string = text
    let range = NSRange(location: 0, length: text.utf16.count)
    tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options){ tag, tokenRange, stop in
        let word = (text as NSString).substring(with: tokenRange)
        //print(word)
        tokenizeDict.updateValue(word, forKey: "Token" + String(word_no))
        word_no = word_no + 1
    }
    return tokenizeDict
}

func lemmatizeWord(text: String) -> Dictionary<String, String> {
    var sentence_no: Int = 0
    var key: String = "lemma"
    tagger.string = text
    let range = NSRange(location: 0, length: text.utf16.count)
    tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options){tag, tokenRange, stop in
        if let lemma = tag?.rawValue {
            sentence_no += 1
            key = key + String(sentence_no)
            lemmatizeDict.updateValue(lemma, forKey: key)
            key = "lemma"
        }
    }
    return lemmatizeDict
}

func partsOfSpeech(text: String) -> Dictionary<String, String> {
    tagger.string = text
    let range = NSRange(location: 0, length: text.utf16.count)
    tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options){tag, tokenRange, _ in
        if let tag = tag {
            var word = (text as NSString).substring(with: tokenRange)
            word = "partsOfSpeech-" + word
            partsOfSpeechDict.updateValue(tag.rawValue, forKey: word)
        }
    }
    return partsOfSpeechDict
}

func entityRecognition(text: String) -> (Dictionary<String, String>, Dictionary<String,String>) {
    var sentence_no: Int = 0
    var index: Int = 0
    var key: String = ""
    let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
    tagger.string = text
    let range = NSRange(location: 0, length: text.utf16.count)
    let opts: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]
    tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: opts) { tag, tokenRange, stop in
        if let tag = tag, tags.contains(tag) {
            let name = (text as NSString).substring(with: tokenRange)
            key = tag.rawValue
            key += ("-" + String(sentence_no))
            entityRecognitionDict.updateValue(name, forKey: key)
            indexDict.updateValue(String(sentence_no), forKey: String(index))
        }
        index = index + 1
        sentence_no = sentence_no + 1
    }
    print(indexDict)
    return (entityRecognitionDict,indexDict)
}
