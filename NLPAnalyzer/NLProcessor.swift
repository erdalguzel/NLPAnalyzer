import Foundation

let tagger = NSLinguisticTagger(tagSchemes: [.lemma, .lexicalClass, .nameType, .tokenType, .language], options: 0)
let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]

var partsOfSpeechDict: Dictionary<String, String> = [:]
var lemmatizeDict: Dictionary<String, String> = [:]
var tokenizeDict: Dictionary<String, String> = [:]
var entityRecognitionDict: Dictionary<String, String> = [:]

struct WordData: Codable {
    var word_identifier: String
    var word: String
}

func traverseDirectory() {
    let documentPath = NSSearchPathForDirectoriesInDomains(.allApplicationsDirectory, .localDomainMask, true)[0]
    let url: URL = URL(fileURLWithPath: documentPath)
    
    let filemanager = FileManager.default
    let enumerator: FileManager.DirectoryEnumerator = filemanager.enumerator(atPath: url.path)!
    while let element = enumerator.nextObject() as? String, element.hasSuffix(".txt") {
        
    }
}

func writeToJSONFile(for filepath: String, messageDictionary: Dictionary<String, String>) {
    var key, value: String
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    for(key, value) in messageDictionary {
        let jsonObject = WordData(word_identifier: messageDictionary[key]!, word: messageDictionary[value]!)
        let encodedData = try! encoder.encode(jsonObject)
        try! encodedData.write(to: URL(fileURLWithPath: filepath))
        //try jsonData.write(to: URL(fileURLWithPath: filepath), options: .atomic)
        //print(jsonString!)
        print(encodedData.description)
    }
}

//Reads text to a string as a whole
func processTextFile(for filepath: String) -> String {
    var text: String = """
"""
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(filepath)
        do {
            text = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print("Cannot read file")
        }
    }
    return text
}

func determineLanguage(for text: String) {
    tagger.string = text
    let lang = tagger.dominantLanguage
    print("Dominant languages is \(lang!)")
}

func tokenizeText(for text: String){
    var word_no: Int = 0
    tagger.string = text
    let range = NSRange(location: 0, length: text.utf8.count)
    tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options){ tag, tokenRange, stop in
        let word = (text as NSString).substring(with: tokenRange)
        //print(word)
        tokenizeDict.updateValue(word, forKey: String(word_no))
        word_no = word_no + 1
    }
}

func lemmatizeWord(for text: String) {
    var sentence_no: Int = 0
    var key: String = "lemma"
    tagger.string = text
    let range = NSRange(location: 0, length: text.utf8.count)
    tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options){tag, tokenRange, stop in
         if let lemma = tag?.rawValue {
            //print(lemma)
            key = "Sentence" + String(sentence_no) + key
            lemmatizeDict.updateValue(lemma, forKey: key)
        }
        sentence_no = sentence_no + 1
    }
}

func partsOfSpeech(for text: String) {
    var sentence_no: Int = 0
    tagger.string = text
    let range = NSRange(location: 0, length: text.utf8.count)
    tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options){tag, tokenRange, _ in
        if let tag = tag {
            var word = (text as NSString).substring(with: tokenRange)
            word = "Sentence" + String(sentence_no) + word
            partsOfSpeechDict.updateValue(tag.rawValue, forKey: word)
            //print("\(word): \(tag.rawValue)")
        }
        sentence_no = sentence_no + 1
    }
}

func entityRecognition(for text: String) {
    var sentence_no: Int = 0
    var key: String = ""
    let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
    tagger.string = text
    let range = NSRange(location: 0, length: text.utf8.count)
    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]
    tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
        if let tag = tag, tags.contains(tag) {
            let name = (text as NSString).substring(with: tokenRange)
            key = tag.rawValue
            key = "Sentence" + String(sentence_no) + key
            entityRecognitionDict.updateValue(name, forKey: key)
        }
        sentence_no = sentence_no + 1
    }
}
