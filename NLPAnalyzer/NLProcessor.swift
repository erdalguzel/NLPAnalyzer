import Foundation

let tagger = NSLinguisticTagger(tagSchemes: [.lemma, .lexicalClass, .nameType, .tokenType, .language], options: 0)
let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]

var partsOfSpeechDict: Dictionary<String, String> = [:]
var lemmatizeDict: Dictionary<String, String> = [:]
var tokenizeDict: Dictionary<String, String> = [:]
var entityRecognitionDict: Dictionary<String, String> = [:]
var indexDict: Dictionary<String,String> = [:]

let openCurlyBracket = "\t{", closedCurlyBracket = "}"
let openSquareBracket = "[", closedSquareBracket = "]"
let comma = ",", colon = " : ", quote = "\"", newline = "\n"
let mixedChars = quote + colon + quote, mixedChars2 = quote + comma + quote, mixedChars3 =  quote + closedCurlyBracket + comma


func readTextFile(filepath: String) -> String {
    var text: String = ""
    text = try! String(contentsOf: URL(fileURLWithPath: filepath))
    return text
}

func tokenizeText(text: String) -> [String:String] {
    var word_no: Int = 1
    tagger.string = text
    let range = NSRange(location: 0, length: text.utf16.count)
    tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options){ tag, tokenRange, stop in
        let word = (text as NSString).substring(with: tokenRange)
        var numstr = String(word_no)
        for _ in numstr.count..<4 {
            numstr = "0" + numstr
        }
        tokenizeDict.updateValue(word, forKey: "Token-" + numstr)
        word_no = word_no + 1
    }
    return tokenizeDict
}

func lemmatize(word: String) -> String {
    var str = ""
    tagger.string = word
    let range = NSRange(location: 0, length: word.utf16.count)
    tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options){tag, tokenRange, stop in
        if let lemma = tag?.rawValue {
            str = lemma
        } else {
            str = "N/A"
        }
    }
    return str
}

func performPartsOfSpeech(word: String) -> String {
    tagger.string = word
    var substr = "", postag = ""
    let range = NSRange(location: 0, length: word.utf16.count)
    tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options){tag, tokenRange, _ in
        if let tag = tag {
            substr = (word as NSString).substring(with: tokenRange)
            postag = tag.rawValue
        } else {
            postag = "N/A"
        }
    }
    return postag
}

func NamedEntityRecognition(word: String) -> String {
    var keystr: String = "", name = ""
    let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
    tagger.string = word
    let range = NSRange(location: 0, length: word.utf16.count)
    let opts: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]
    tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: opts) { tag, tokenRange, stop in
        if let tag = tag, tags.contains(tag) {
            name = (word as NSString).substring(with: tokenRange)
            keystr = tag.rawValue
        } else {
            keystr = "N/A"
        }
    }
    return keystr
}

func writeAsJSONFile(paramDict1: [String:String], paramDict2: [String:String], paramDict3: [String:String], filepath: String) {
    let keys = getDictionaryKeys(dict: paramDict1)
    var indexes: [String] = []
    for x in 0..<keys.count {
        let index = getSuffix(forString: keys[x])
        indexes.append(index)
    }
    
    writeString(whichString: openSquareBracket, filepath: filepath)
    writeString(whichString: newline, filepath: filepath)
    
    for i in 0..<paramDict1.count {
        writeString(whichString: openCurlyBracket, filepath: filepath)
        writeString(whichString: quote, filepath: filepath)
        writeString(whichString: "Token" + mixedChars, filepath: filepath)
        writeString(whichString: paramDict1[keys[i]]! + mixedChars2, filepath: filepath)
        writeString(whichString: "Lemma" + mixedChars, filepath: filepath)
        writeString(whichString: paramDict2[keys[i]]! + mixedChars2, filepath: filepath)
        writeString(whichString: "POS" + mixedChars, filepath: filepath)
        writeString(whichString: paramDict3[keys[i]]! + quote + comma, filepath: filepath)
        writeString(whichString: quote + "id" + mixedChars, filepath: filepath)
        writeString(whichString: indexes[i] + mixedChars3, filepath: filepath)
        writeString(whichString: newline, filepath: filepath)
    }
    writeString(whichString: closedSquareBracket, filepath: filepath)
}

func writeNERAsJSONFile(paramDict: [String:String], filepath: String) {
    let keys = getDictionaryKeys(dict: paramDict)
    var indexes: [String] = []
    for k in 0..<keys.count{
        let index = getSuffix(forString: keys[k])
        indexes.append(index)
    }
    writeString(whichString: openSquareBracket, filepath: filepath)
    writeString(whichString: newline, filepath: filepath)
    
    for a in 0..<paramDict.count {
        writeString(whichString: openCurlyBracket, filepath: filepath)
        writeString(whichString: quote, filepath: filepath)
        writeString(whichString: "NER" + mixedChars, filepath: filepath)
        writeString(whichString: paramDict[keys[a]]! + mixedChars2, filepath: filepath)
        writeString(whichString: "id" + mixedChars, filepath: filepath)
        writeString(whichString: indexes[a] + mixedChars3, filepath: filepath)
        writeString(whichString: newline, filepath: filepath)
    }
    writeString(whichString: closedSquareBracket, filepath: filepath)
}


func writeString(whichString: String, filepath: String) {
    let manager = FileManager.default
    if manager.fileExists(atPath: filepath) == false {
        manager.createFile(atPath: filepath, contents: nil, attributes: nil)
    }
    if let fileUpdater = try? FileHandle(forUpdating: URL(fileURLWithPath: filepath)) {
        fileUpdater.seekToEndOfFile()
        fileUpdater.write(whichString.data(using: String.Encoding.utf8)!)
    }
}

func getDictionaryKeys(dict: [String:String]) -> Array<String> {
    return Array(dict.keys.sorted(by: <))
}

func getSuffix(forString: String) -> String {
    var number = ""
    if let index = forString.range(of: "-")?.upperBound {
        let substring = forString.suffix(from: index)
        number = String(substring)
    }
    return number
}

func getFilenames(path: String) -> [String] {
    let manager = FileManager.default
    let files = try! manager.contentsOfDirectory(atPath: path)
    return files
}

//Extracts folder names when needed
func extractFileName(filepath: NSString) -> String {
    let lastComponent: NSString = filepath.deletingPathExtension as NSString
    let filename = lastComponent.lastPathComponent
    return filename
}

func isDirectory(filepath: String) -> Bool {
    let manager = FileManager.default
    let url = URL(string: filepath + "/")
    if (url?.hasDirectoryPath)! && manager.fileExists(atPath: (url?.absoluteString)!){
        return true
    } else {
        return false
    }
}
