//
//  ViewController.swift
//  MyCoreDataSample
//
//  Created by Tasuku Tozawa on 2020/11/03.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var container: NSPersistentContainer!
    var controller: NSFetchedResultsController<Note>!

    enum Section {
        case main
    }

    @IBOutlet weak var tableView: UITableView!
    private var dataSource: MyDataSource!

    private var notes: [NoteModel] = [] {
        didSet {
            var snapshot = NSDiffableDataSourceSnapshot<Section, NoteModel>()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.notes)
            self.dataSource.apply(snapshot)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.didTapAdd(_:)))

        self.tableView.register(NoteCell.nib, forCellReuseIdentifier: "Cell")
        self.dataSource = MyDataSource(tableView: self.tableView) {
            (tableView: UITableView, indexPath: IndexPath, itemIdentifier: NoteModel) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? NoteCell else { return nil }
            cell.note = itemIdentifier
            return cell
        }
        self.dataSource.container = self.container
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self

        let request = NSFetchRequest<Note>(entityName: "Note")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        self.controller = NSFetchedResultsController(fetchRequest: request,
                                                     managedObjectContext: self.container.viewContext,
                                                     sectionNameKeyPath: nil,
                                                     cacheName: nil)
        self.controller.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        try! self.controller.performFetch()
    }

    @objc
    func didTapAdd(_ sender: UIBarButtonItem) {
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note",
                                                       into: self.container.viewContext) as! Note
        note.id = UUID()
        note.title = "Untitled"
        note.updatedAt = Date()
        note.createdAt = Date()
        try? self.container.viewContext.save()
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    // MARK: - NSFetchedResultsControllerDelegate

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>

        let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
            guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
            return itemIdentifier
        }
        snapshot.reloadItems(reloadIdentifiers)

        self.notes = snapshot.itemIdentifiers
            .compactMap { controller.managedObjectContext.object(with: $0) as? Note }
            .compactMap { $0.map(to: NoteModel.self) }
    }
}

extension ViewController: UITableViewDelegate {
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let note = self.dataSource.itemIdentifier(for: indexPath) else { return }
        let nextViewController = EditViewController()
        nextViewController.container = self.container
        nextViewController.note = note
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}

class MyDataSource: UITableViewDiffableDataSource<ViewController.Section, NoteModel> {
    weak var container: NSPersistentContainer?

    // MARK: - Overrides (UITableViewDataSource)

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let note = self.itemIdentifier(for: indexPath) else { return }

        let request = NSFetchRequest<Note>(entityName: "Note")
        request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)

        guard let deleteTarget = try? self.container?.viewContext.fetch(request).first else { return }

        self.container?.viewContext.delete(deleteTarget)
        try? self.container?.viewContext.save()
    }
}
