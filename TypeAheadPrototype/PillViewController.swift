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
import os

class PillViewController: UICollectionViewController {
    let delegate = ResultsCollectionViewDelegate()
    var selectCallback: (String) -> () = { _ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate.callback = self.selectCallback
        collectionView.dataSource = delegate
        collectionView.delegate = delegate
        
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: "MatchLabelCell")
        
        let noteName = UIContentSizeCategory.didChangeNotification
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeChange), name: noteName, object: nil)
        setEstimatedSizeIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { [weak self] (_) -> () in
            self?.collectionViewLayout.invalidateLayout()
            self?.collectionView.reloadData()
        }
    }
    
    func setEstimatedSizeIfNeeded() {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout;
        let estimatedWidth: CGFloat = 50
        if flowLayout.estimatedItemSize.width != estimatedWidth {
            flowLayout.estimatedItemSize = CGSize(width: estimatedWidth, height: 30)
            flowLayout.invalidateLayout()
        }
    }
    
    @objc func handleContentSizeChange() {
        delegate.resetCache()
        setEstimatedSizeIfNeeded()
        collectionView.reloadData()
    }
    
    func setSuggestions(suggestions: [String]) {
        delegate._suggestions = suggestions
        collectionView.reloadData()
        collectionViewLayout.invalidateLayout()
    }
    
    func selectCallback(_ suggestion: String) {
        selectCallback(suggestion)
    }
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
}

class ResultsCollectionViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var _suggestions: [String] = []
    var callback: (String) -> () = { _ in }
    var _cache: [String: CGFloat] = [:]
    var _layoutLog = OSLog(subsystem: "PillCollectionViewDelegate", category: "layout")
    var _dequeueLog = OSLog(subsystem: "PillCollectionViewDelegate", category: "dequeue")
    
    func resetCache() {
        _cache = [:]
    }
    
    // Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let suggestion = _suggestions[indexPath.row]
        callback(suggestion)
    }
    
    // Flow Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 30
        let inset: CGFloat = 30
        
        let suggestion = _suggestions[indexPath.row]
        os_signpost(.begin, log: _layoutLog, name: "Layout Pill Cell", "%{public}s", suggestion)
        
        if let cached = _cache[suggestion] {
            os_signpost(.end, log: _layoutLog, name: "Layout Pill Cell")
            return CGSize(width: cached + inset, height: height)
        }
        
        let width = suggestion.width(withConstrainedHeight: height, font: UIFont.preferredFont(forTextStyle: .body))
        _cache[suggestion] = width
        
        os_signpost(.end, log: _layoutLog, name: "Layout Pill Cell")
        return CGSize(width: width + inset, height: height)
    }
    
    // Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _suggestions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let suggestion = _suggestions[indexPath.row]
        os_signpost(.begin, log: _dequeueLog, name: "Dequeue Pill Cell", "%{public}s", suggestion)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchLabelCell", for: indexPath) as! LabelCell
        cell.labelText = suggestion
        
        os_signpost(.end, log: _dequeueLog, name: "Dequeue Pill Cell")
        return cell
    }
}
