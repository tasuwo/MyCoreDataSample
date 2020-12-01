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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                 target: self,
                                                                 action: #selector(self.didTapSave(_:)))

        self.titleTextField.text = self.note.title
        self.uuidLabel.text = self.note.id.uuidString
        self.updatedAtLabel.text = self.note.updatedAt.string
        self.createdAtLabel.text = self.note.createdAt.string
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
}
