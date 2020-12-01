//
//  EditViewController.swift
//  MyCoreDataSample
//
//  Created by Tasuku Tozawa on 2020/11/03.
//

import UIKit
import CoreData

class EditViewController: UIViewController {
    var container: NSPersistentContainer!
    var note: NoteModel!

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save,
                                         target: self,
                                         action: #selector(self.didTapSave(_:)))
        let addTagButton = UIBarButtonItem(barButtonSystemItem: .add,
                                           target: self,
                                           action: #selector(self.didTapAddTag(_:)))
        self.navigationItem.rightBarButtonItems = [saveButton, addTagButton]

        self.titleTextField.text = self.note.title
        self.uuidLabel.text = self.note.id.uuidString
        self.updatedAtLabel.text = self.note.updatedAt.string
        self.createdAtLabel.text = self.note.createdAt.string
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

    @objc
    func didTapSave(_ sender: UIBarButtonItem) {
        let request = NSFetchRequest<Note>(entityName: "Note")
        request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
        guard let target = try? self.container?.viewContext.fetch(request).first else { return }

        target.title = self.titleTextField.text
        target.updatedAt = Date()

        try! self.container?.viewContext.save()

        self.navigationController?.popViewController(animated: true)
    }

    @objc
    func didTapAddTag(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "タグを追加", message: nil, preferredStyle: .alert)
        let addNewTagAction = UIAlertAction(title: "新規タグを追加", style: .default) { [unowned self] _ in
            self.addNewTag()
        }
        let addOldTagAction = UIAlertAction(title: "既存のタグを追加", style: .default) { [unowned self] _ in
            self.addOldTag()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        alert.addAction(addNewTagAction)
        alert.addAction(addOldTagAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }

    private func addNewTag() {
        let alert = UIAlertController(title: "タグを追加", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "タグ名"
        }

        let saveAction = UIAlertAction(title: "保存", style: .default) { [unowned self] _ in
            let request = NSFetchRequest<Note>(entityName: "Note")
            request.predicate = NSPredicate(format: "id == %@", self.note.id as CVarArg)
            guard let note = try? self.container?.viewContext.fetch(request).first else { return }

            guard
                let context = self.container?.viewContext,
                let textField = alert.textFields?.first,
                let text = textField.text else {
                return
            }

            let tag = Tag(context: context)
            tag.id = UUID()
            tag.name = text
            tag.addToNotes(note)

            try! context.save()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }

    private func addOldTag() {
        // WIP
    }
}
