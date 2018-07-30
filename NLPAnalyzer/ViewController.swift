import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var lemmatizeCheckBox: NSButton!
    @IBOutlet weak var tokenizeBox: NSButton!
    @IBOutlet weak var partsOfSpeechBox: NSButton!
    @IBOutlet weak var recognitionBox: NSButton!
    
    @IBOutlet weak var inputPathTextField: NSTextField!
    @IBOutlet weak var outputPathTextField: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!

    var POSDict: Dictionary<String, String> = [:]
    var lemmaDict: Dictionary<String, String> = [:]
    var tokenDict: Dictionary<String, String> = [:]
    var entityRecognitionDict: Dictionary<String, String> = [:]
    var filenameArray: [String] = [], nameArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func fileSelector(_ sender: AnyObject) {
        let dialog = NSOpenPanel()
        
        dialog.title = "Choose a file"
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = true
        dialog.showsResizeIndicator = true
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let result = dialog.url
            if result != nil {
                let path = result!.path
                inputPathTextField.stringValue = path
            }
        } else {
            return
        }
    }
    
    @IBAction func pathSelector(_ sender: AnyObject) {
        let dialog = NSOpenPanel()
        
        dialog.title = "Choose a path"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let result = dialog.url
            
            if result != nil {
                let path = result!.path
                outputPathTextField.stringValue = path
            }
        } else {
            return
        }
    }
    
    
    @IBAction func startButton(_ sender: NSButton) {
        let out_fname: String = ""
        var inputFileString: String = ""
        var outputFilepath: String = outputPathTextField.stringValue
        let fileList = getFilenames(path: outputFilepath)
//        print(fileList)

//        if !fileList.isEmpty {
//            print("This is a directory\n")
//            print("files:", fileList)
//            for item in fileList {
//                inputFileString = readTextFile(filepath: inputPathTextField.stringValue + item)
//                outputFilepath += ("/" + item)
//            }
//        } else {
//            print("This is a file\n")
            inputFileString = readTextFile(filepath: inputPathTextField.stringValue)
            beginProcess(inputText: inputFileString, output_filename: out_fname, outputPath: outputFilepath)
//        }
    }
    
    func beginProcess(inputText: String, output_filename: String, outputPath: String) {
        var temp_outfname = output_filename, temp_outPath = outputPath
        tokenDict = tokenizeText(text: inputText)
        temp_outfname = extractFileName(filepath: inputPathTextField.stringValue as NSString)
        temp_outfname = temp_outfname + ".morph.json"
        (lemmaDict,POSDict,entityRecognitionDict) = fillDictionaries(dict: tokenDict)
        
        if tokenizeBox.state == .off {
            for (k,_) in tokenDict {
                tokenDict[k] = ""
            }
        }
        if lemmatizeCheckBox.state == .off {
            for (k,_) in lemmaDict {
                lemmaDict[k] = ""
            }
        }
        if partsOfSpeechBox.state == .off {
            for (k,_) in POSDict {
                POSDict[k] = ""
            }
        }
        
        temp_outPath += ("/" + temp_outfname)
        writeAsJSONFile(paramDict1: tokenDict, paramDict2: lemmaDict, paramDict3: POSDict, filepath: temp_outPath)
        
        temp_outPath = outputPathTextField.stringValue
        temp_outfname = extractFileName(filepath: inputPathTextField.stringValue as NSString)
        temp_outfname += ".NER.json"
        temp_outPath += ("/" + temp_outfname)
        if recognitionBox.state == .off {
            for (k,_) in entityRecognitionDict {
                entityRecognitionDict[k] = ""
            }
        }
        writeNERAsJSONFile(paramDict: entityRecognitionDict, filepath: temp_outPath)
    }
    
    func fillDictionaries(dict: [String:String]) -> ([String:String], [String:String], [String:String]) {
        var tempDict1 = dict, tempDict2: [String:String] = [:], tempDict3: [String:String] = [:], tempDict4: [String:String] = [:]
        var newstr = "", pos = "", ner = ""
        let sortedKeys = Array(tempDict1.keys).sorted(by: <)
        var index = 0
        
        for (_, _) in tempDict1 {
            let key = sortedKeys[index]
            let value = tempDict1[key]
            newstr = lemmatize(word: value!)
            tempDict2.updateValue(newstr, forKey: key)
            pos = performPartsOfSpeech(word: value!)
            tempDict3.updateValue(pos, forKey: key)
            ner = NamedEntityRecognition(word: value!)
            tempDict4.updateValue(ner, forKey: key)
            index += 1
        }

        for (key,value) in tempDict4 {
            if value == "N/A" {
                tempDict4.removeValue(forKey: key)
            }
        }
        return (tempDict2,tempDict3,tempDict4)
    }
}
