//
//  KeywordsViewController.swift
//  operation-queue-ios
//
//  Created by Ramunas Jurgilas on 2017-04-11.
//  Copyright © 2017 Ramūnas Jurgilas. All rights reserved.
//

import UIKit
import MessageUI

class KeywordsViewController: UIViewController, UIDocumentMenuDelegate, UIDocumentPickerDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var removeKeywordsSwitch: UISwitch!
    @IBOutlet weak var fileNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var keywordsLabel: UILabel!
    
    var fileContent: String = "NA"
    var keywords = [String]()


    @IBAction func didClickPickDocument(_ sender: UIButton) {
        let documentPicker = UIDocumentMenuViewController(documentTypes: ["public.data"], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }

    @IBAction func didClickExportButton(_ sender: UIButton) {
        let countedKeywords = fileContent.countKeywords(keywords).description
        
        var result = fileContent
        if removeKeywordsSwitch.isOn {
            result = fileContent.removeKeywords(keywords)
        }
        send(fileContent: result, countedKeywords: countedKeywords)
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
    
    @IBAction func didClickResetKeywordsButton(_ sender: UIButton) {
        keywordsLabel.text = nil
        keywords = [String]()
    }
    
    @IBAction func didClickAddKeyword(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Add keyword", message: nil, preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            if let keywordTextField = (alertController.textFields![0] as UITextField?),
                let keyword = keywordTextField.text {
                self.keywords.append(keyword)
                self.keywordsLabel.text = self.keywords.joined(separator: ", ")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Keyword"
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true) {
        }
    }
    
    @IBAction func didClickDoneButton(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject("Export files")
        
        return mailComposerVC
    }
    
    func send(fileContent: String, countedKeywords: String) {
        let text = String(format: "----- Counted keywords --------\n\n%@ \n\n------- File content ------ \n\n%@", countedKeywords, fileContent)
        let mailComposeViewController = configuredMailComposeViewController()
        mailComposeViewController.setMessageBody(text, isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
