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
            self.titleLabel.text = note.title
            self.uuidLabel.text = note.id.uuidString
            self.createdAtLabel.text = note.createdAt.string
            self.updatedAtLabel.text = note.updatedAt.string
            if note.tags.isEmpty {
                self.tagsLabel.text = "No Tags"
                self.tagsLabel.textColor = .secondaryLabel
            } else {
                self.tagsLabel.text = note.tags
                    .map { $0.name }
                    .joined(separator: ", ")
                self.tagsLabel.textColor = .label
            }
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
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
