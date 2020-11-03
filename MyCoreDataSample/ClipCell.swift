//
//  ClipCell.swift
//  MyCoreDataSample
//
//  Created by Tasuku Tozawa on 2020/11/03.
//

import UIKit

class ClipCell: UITableViewCell {
    static var nib: UINib {
        return UINib(nibName: "ClipCell", bundle: Bundle(for: Self.self))
    }

    var clip: ViewController.ClipModel? {
        didSet {
            guard let clip = self.clip else { return }
            self.uuidLabel.text = clip.id.uuidString
            self.descriptionLabel.text = clip.descriptionText
            self.isHiddenLabel.text = clip.isHidden ? "Yes" : "No"
            self.registeredDateLabel.text = clip.registeredDate.string
            self.updatedDateLabel.text = clip.updatedDate.string
            self.tagsLabel.text = clip.tags.map { $0.name }.joined(separator: ",")
        }
    }

    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var isHiddenLabel: UILabel!
    @IBOutlet weak var registeredDateLabel: UILabel!
    @IBOutlet weak var updatedDateLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
}

extension Date {
    var string: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }
}
