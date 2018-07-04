import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var lemmatizeCheckBox: NSButton!
    @IBOutlet weak var recognitionBox: NSButton!
    @IBOutlet weak var tokenizeBox: NSButton!
    @IBOutlet weak var speechBox: NSButton!
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
        //dialog.nameFieldStringValue
        
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
        
        if speechBox.state == .on {
            filenameString = "PartsOfSpeech" + String(fileNo) + ".json"
            inputFileString = processTextFile(for: inputPathTextField.stringValue)
            outputFilepath = outputPathTextField.stringValue
            partsOfSpeech(for: inputFileString)
            writeToJSONFile(for: outputFilepath, messageDictionary: partsOfSpeechDict2)
            progressBar.increment(by: 25.0)
        } else if tokenizeBox.state == .on {
            filenameString = "Tokenize" + String(fileNo) + ".json"
            inputFileString = processTextFile(for: inputPathTextField.stringValue)
            outputFilepath = outputPathTextField.stringValue
            tokenizeText(for: inputFileString)
            writeToJSONFile(for: outputFilepath, messageDictionary: tokenizeDict2)
            progressBar.increment(by: 25.0)
        } else if recognitionBox.state == .on {
            filenameString = "EntityRecognition" + String(fileNo) + ".json"
            inputFileString = processTextFile(for: inputPathTextField.stringValue)
            outputFilepath = outputPathTextField.stringValue
            entityRecognition(for: inputFileString)
            writeToJSONFile(for: outputFilepath, messageDictionary: entityRecognitionDict2)
            progressBar.increment(by: 25.0)
        } else if lemmatizeCheckBox.state == .on {
            filenameString = "PartsOfSpeech" + String(fileNo) + ".json"
            inputFileString = processTextFile(for: inputPathTextField.stringValue)
            outputFilepath = outputPathTextField.stringValue
            lemmatizeWord(for: inputFileString)
            writeToJSONFile(for: outputFilepath, messageDictionary:  lemmatizeDict2)
            progressBar.increment(by: 25.0)
        } else {
            return
        }
    }
    //Performs specific action when start button is pressed
    /*
    @IBAction func analyzeText(_ sender: NSButton) {
        
        var fileNo: Int = 0
        var filenameString: String = ""
        var inputFileString: String = ""
        var outputFilepath: String = ""
        
        if speechBox.state == .on {
            filenameString = "PartsOfSpeech" + String(fileNo) + ".json"
            inputFileString = processTextFile(for: inputPathTextField.stringValue)
            outputFilepath = outputPathTextField.stringValue
            partsOfSpeech(for: inputFileString)
            writeToJSONFile(for: outputFilepath, messageDictionary: partsOfSpeechDict2)
            progressBar.increment(by: 25.0)
        } else if tokenizeBox.state == .on {
            filenameString = "Tokenize" + String(fileNo) + ".json"
            inputFileString = processTextFile(for: inputPathTextField.stringValue)
            outputFilepath = outputPathTextField.stringValue
            tokenizeText(for: inputFileString)
            writeToJSONFile(for: outputFilepath, messageDictionary: tokenizeDict2)
            progressBar.increment(by: 25.0)
        } else if recognitionBox.state == .on {
            filenameString = "EntityRecognition" + String(fileNo) + ".json"
            inputFileString = processTextFile(for: inputPathTextField.stringValue)
            outputFilepath = outputPathTextField.stringValue
            entityRecognition(for: inputFileString)
            writeToJSONFile(for: outputFilepath, messageDictionary: entityRecognitionDict2)
            progressBar.increment(by: 25.0)
        } else if lemmatizeCheckBox.state == .on {
            filenameString = "PartsOfSpeech" + String(fileNo) + ".json"
            inputFileString = processTextFile(for: inputPathTextField.stringValue)
            outputFilepath = outputPathTextField.stringValue
            lemmatizeWord(for: inputFileString)
            writeToJSONFile(for: outputFilepath, messageDictionary:  lemmatizeDict2)
            progressBar.increment(by: 25.0)
        } else {
            return
        }
    }
 */
}
