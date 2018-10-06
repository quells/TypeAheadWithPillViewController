//
//  TypeAheadWithPillViewController.swift
//  TypeAheadPrototype
//
//  Copyright (c) 2018 Kai Wells (https://github.com/quells)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

class TypeAheadWithPillViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var _textField: UITextField!
    weak var pillViewController: PillViewController?
    
    lazy var categories = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]

    override func viewDidLoad() {
        super.viewDidLoad()
        _textField.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var search = textField.text ?? ""
        search.replaceSubrange(Range(range, in: search)!, with: string)
        search = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if search.count > 0 {
            let matches = categories
                .filter { $0.lowercased().contains(search) }
            pillViewController?.setSuggestions(suggestions: matches)
        } else {
            pillViewController?.setSuggestions(suggestions: [])
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func handle(_ suggestion: String) {
        _textField.text = suggestion
        pillViewController?.setSuggestions(suggestions: [])
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "embedPillController":
            guard let pvc = segue.destination as? PillViewController else {
                fatalError("Could not find PillViewController")
            }
            pvc.selectCallback = self.handle
            self.pillViewController = pvc
        default:
            print(segue.identifier ?? "prep for segue w/o identifier?")
        }
    }
}
