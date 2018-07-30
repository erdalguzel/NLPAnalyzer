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
        var out_fname: String = ""
        let inputFileString: String = readTextFile(filepath: inputPathTextField.stringValue)
        var outputFilepath: String = outputPathTextField.stringValue
        let fileList = getFilenames(path: outputFilepath)
//        print(fileList)

        tokenDict = tokenizeText(text: inputFileString)
        out_fname = extractFileName(filepath: inputPathTextField.stringValue as NSString)
        out_fname = out_fname + ".morph.json"
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

        outputFilepath += ("/" + out_fname)
        writeAsJSONFile(paramDict1: tokenDict, paramDict2: lemmaDict, paramDict3: POSDict, filepath: outputFilepath)
        
        outputFilepath = outputPathTextField.stringValue
        out_fname = extractFileName(filepath: inputPathTextField.stringValue as NSString)
        out_fname += ".NER.json"
        outputFilepath += ("/" + out_fname)
        if recognitionBox.state == .off {
            for (k,_) in entityRecognitionDict {
                entityRecognitionDict[k] = ""
            }
        }
        writeNERAsJSONFile(paramDict: entityRecognitionDict, filepath: outputFilepath)
    }
    
    func fillDictionaries(dict: [String:String]) -> ([String:String], [String:String], [String:String]) {
        var tempDict1 = dict, tempDict2: [String:String] = [:], tempDict3: [String:String] = [:], tempDict4: [String:String] = [:]
        var newstr = "", pos = "", ner = ""
        let sortedKeys = Array(tempDict1.keys).sorted(by: <)
        var index = 0
        
        for (key, _) in tempDict1 {
            let value = tempDict1[sortedKeys[index]]
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
