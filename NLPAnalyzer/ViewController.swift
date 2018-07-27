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
        var inputFileString: String = ""
        var outputFilepath: String = ""
        
        inputFileString = readTextFile(filepath: inputPathTextField.stringValue)
        tokenDict = tokenizeText(text: inputFileString)
        outputFilepath = outputPathTextField.stringValue
        out_fname = extractFileName(filepath: inputPathTextField.stringValue as NSString)
        out_fname = out_fname + ".morph.json"
        
        var newstr = "", pos = "", ner = ""
        for (key, value) in tokenDict {
            newstr = lemmatize(word: value)
            lemmaDict.updateValue(newstr, forKey: key)
            pos = performPartsOfSpeech(word: value)
            POSDict.updateValue(pos, forKey: key)
            ner = NamedEntityRecognition(word: value)
            entityRecognitionDict.updateValue(ner, forKey: key)
        }
        outputFilepath += ("/" + out_fname)
        
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
            for (k,_) in partsOfSpeechDict {
                partsOfSpeechDict[k] = ""
            }
        }
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
}
