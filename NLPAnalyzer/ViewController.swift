import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var lemmatizeCheckBox: NSButton!
    @IBOutlet weak var tokenizeBox: NSButton!
    @IBOutlet weak var partsOfSpeechBox: NSButton!
    @IBOutlet weak var recognitionBox: NSButton!
    
    @IBOutlet weak var inputPathTextField: NSTextField!
    @IBOutlet weak var outputPathTextField: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    var partsOfSpeechDict2: Dictionary<String, String> = [:]
    var lemmatizeDict2: Dictionary<String, String> = [:]
    var tokenizeDict2: Dictionary<String, String> = [:]
    var entityRecognitionDict2: Dictionary<String, String> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func fileSelector(_ sender: AnyObject) {
        let dialog = NSOpenPanel()
        
        dialog.title = "Choose a file"
        dialog.allowsMultipleSelection = true
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
        
        var fileNo: Int = 0
        var filenameString: String = ""
        var inputFileString: String = ""
        var outputFilepath: String = ""
        
        if partsOfSpeechBox.state == .on {
            filenameString = "PartsOfSpeech" + String(fileNo) + ".json"
            inputFileString = readTextFile(filepath: inputPathTextField.stringValue)
            outputFilepath = outputPathTextField.stringValue
            partsOfSpeechDict2 = partsOfSpeech(text: inputFileString)
            writeToJSONFile(filepath: outputFilepath, filename: filenameString, messageDictionary:partsOfSpeechDict2)
        }
        if tokenizeBox.state == .on {
            filenameString = "Tokenize" + String(fileNo) + ".json"
            inputFileString = readTextFile(filepath: inputPathTextField.stringValue)
            outputFilepath = outputPathTextField.stringValue
            tokenizeDict2 = tokenizeText(text: inputFileString)
            writeToJSONFile(filepath: outputFilepath, filename: filenameString, messageDictionary:tokenizeDict2)
        }
        if recognitionBox.state == .on {
            filenameString = "EntityRecognition" + String(fileNo) + ".json"
            inputFileString = readTextFile(filepath: inputPathTextField.stringValue)
            outputFilepath = outputPathTextField.stringValue
            entityRecognitionDict2 = entityRecognition(text: inputFileString)
            writeToJSONFile(filepath: outputFilepath, filename: filenameString, messageDictionary:entityRecognitionDict2)
        }
        if lemmatizeCheckBox.state == .on {
            filenameString = "Lemmatize" + String(fileNo) + ".json"
            inputFileString = readTextFile(filepath: inputPathTextField.stringValue)
            outputFilepath = outputPathTextField.stringValue
            lemmatizeDict2 = lemmatizeWord(text: inputFileString)
            writeToJSONFile(filepath: outputFilepath, filename: filenameString, messageDictionary:lemmatizeDict2)
        }
        else {
            return
        }
        fileNo += 1
    }
    
    func extractFileName(filepath: NSString) -> String {
        let lastComponent: NSString = filepath.deletingPathExtension as NSString
        let filename = lastComponent.lastPathComponent
        return filename
    }
}
