//
//  LabelCell.swift
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

extension UILabel {
    func useSystemFont() {
        self.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    func monitorFontSizeChanges() {
        let noteName = UIContentSizeCategory.didChangeNotification
        NotificationCenter.default.addObserver(forName: noteName, object: nil, queue: OperationQueue.main) { [weak self] (_) -> () in
            self?.font = UIFont.preferredFont(forTextStyle: .body)
        }
    }
}

class LabelCell: UICollectionViewCell {
    var label: UILabel
    
    var labelText: String {
        didSet {
            label.text = labelText
        }
    }
    
    var isHeightCalculated: Bool = false
    
    override init(frame: CGRect) {
        label = UILabel(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.useSystemFont()
        label.textAlignment = .center
        label.textColor = .white
        
        labelText = ""
        
        super.init(frame: frame)
        contentView.backgroundColor = .gray
        contentView.layer.cornerRadius = 15
        contentView.layer.maskedCorners = CACornerMask.init(rawValue: 15)
        
        let noteName = UIContentSizeCategory.didChangeNotification
        NotificationCenter.default.addObserver(forName: noteName, object: nil, queue: OperationQueue.main) { [weak self] (_) -> () in
            self?.label.useSystemFont()
            self?.isHeightCalculated = false
        }
        
        contentView.addSubview(label)
        let views = ["label": label]
        let nullLayoutFormatOptions = NSLayoutConstraint.FormatOptions.init(rawValue: 0)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label(>=0)]-10-|", options: nullLayoutFormatOptions, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[label(30)]-0-|", options: nullLayoutFormatOptions, metrics: nil, views: views))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        if !isHeightCalculated {
            setNeedsLayout()
            layoutIfNeeded()
            let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
            var newFrame = layoutAttributes.frame
            newFrame.size.width = CGFloat(ceilf(Float(size.width)))
            layoutAttributes.frame = newFrame
            isHeightCalculated = true
        }
        return layoutAttributes
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
