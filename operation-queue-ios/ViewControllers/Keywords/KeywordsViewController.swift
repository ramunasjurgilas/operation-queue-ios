//
//  KeywordsViewController.swift
//  operation-queue-ios
//
//  Created by Ramunas Jurgilas on 2017-04-11.
//  Copyright © 2017 Ramūnas Jurgilas. All rights reserved.
//

import UIKit

class KeywordsViewController: UIViewController, UIDocumentMenuDelegate, UIDocumentPickerDelegate {

    @IBOutlet weak var fileNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var keywordsTextView: UITextView!
    var fileContent: String?
    var keywords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func didClickPickDocument(_ sender: UIButton) {
        let documentPicker = UIDocumentMenuViewController(documentTypes: ["public.data"], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }

    @IBAction func didClickUploadButton(_ sender: UIButton) {
        let countedResult = fileContent?.countKeywords(keywords)
        print(countedResult?.debugDescription ?? "No value")
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        do {
            fileContent = try String(contentsOf: url, encoding: .utf8)
        }
        catch {
            fileNameTextField.text = error.localizedDescription
        }
    }
    
    // MARK: - UIDocumentMenuDelegate
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }

}
