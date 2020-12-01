//
//  NoteCell.swift
//  MyCoreDataSample
//
//  Created by Tasuku Tozawa on 2020/11/03.
//

import UIKit

class NoteCell: UITableViewCell {
    static var nib: UINib {
        return UINib(nibName: "NoteCell", bundle: Bundle(for: Self.self))
    }

    var note : NoteModel? {
        didSet {
            guard let note = self.note else { return }
            self.uuidLabel.text = note.id.uuidString
            // self.descriptionLabel.text = note.descriptionText
            // self.isHiddenLabel.text = note.isHidden ? "Yes" : "No"
            self.registeredDateLabel.text = note.createdAt.string
            self.updatedDateLabel.text = note.updatedAt.string
            // self.tagsLabel.text = note.tags.map { $0.name }.joined(separator: ",")
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
