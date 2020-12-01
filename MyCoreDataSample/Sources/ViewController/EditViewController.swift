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
    var clip: ViewController.ClipModel!

    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var isHiddenSwitch: UISwitch!
    @IBOutlet weak var updateDatePicker: UIDatePicker!
    @IBOutlet weak var registeredDateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                 target: self,
                                                                 action: #selector(self.didTapSave(_:)))

        self.uuidLabel.text = self.clip.id.uuidString
        self.descriptionTextField.text = self.clip.descriptionText
        self.isHiddenSwitch.isOn = self.clip.isHidden
        self.updateDatePicker.date = self.clip.updatedDate
        self.registeredDateLabel.text = self.clip.registeredDate.string
    }

    @objc
    func didTapSave(_ sender: UIBarButtonItem) {
        let request = NSFetchRequest<Clip>(entityName: "Clip")
        request.predicate = NSPredicate(format: "id == %@", clip.id as CVarArg)
        guard let target = try? self.container?.viewContext.fetch(request).first else { return }

        target.descriptionText = self.descriptionTextField.text
        target.isHidden = self.isHiddenSwitch.isOn
        target.updatedDate = self.updateDatePicker.date

        try! self.container?.viewContext.save()
    }
}
