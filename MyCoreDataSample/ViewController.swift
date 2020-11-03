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
    var controller: NSFetchedResultsController<Clip>!

    enum Section {
        case main
    }

    struct ClipModel: Equatable, Hashable {
        let id: UUID
        let descriptionText: String?
        let isHidden: Bool
        let registeredDate: Date
        let updatedDate: Date
        let tags: [TagModel]

        init(id: UUID) {
            self.id = id
            self.descriptionText = nil
            self.isHidden = false
            self.registeredDate = Date(timeIntervalSince1970: 0)
            self.updatedDate = Date(timeIntervalSince1970: 0)
            self.tags = []
        }

        init?(clip: Clip) {
            guard let id = clip.id,
                  let registeredDate = clip.registeredDate,
                  let updatedDate = clip.updatedDate else {
                return nil
            }
            self.id = id
            self.descriptionText = clip.descriptionText
            self.isHidden = clip.isHidden
            self.registeredDate = registeredDate
            self.updatedDate = updatedDate
            self.tags = clip.tags?.allObjects
                .compactMap { $0 as? Tag }
                .compactMap { TagModel(tag: $0) } ?? []
        }
    }

    struct TagModel: Equatable, Hashable {
        let id: UUID
        let name: String
        let clips: [ClipModel]

        init?(tag: Tag) {
            guard let id = tag.id,
                  let name = tag.name else {
                return nil
            }
            self.id = id
            self.name = name
            self.clips = tag.clips?.allObjects
                .compactMap { $0 as? Clip }
                .compactMap { ClipModel(clip: $0) } ?? []
        }
    }

    @IBOutlet weak var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Section, ClipModel>!

    private var clips: [ClipModel] = [] {
        didSet {
            var snapshot = NSDiffableDataSourceSnapshot<Section, ClipModel>()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.clips)
            self.dataSource.apply(snapshot)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.didTapAdd(_:)))

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.dataSource = UITableViewDiffableDataSource<Section, ClipModel>(tableView: self.tableView) {
            (tableView: UITableView, indexPath: IndexPath, itemIdentifier: ClipModel) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else { return nil }
            cell.textLabel?.text = itemIdentifier.id.uuidString
            return cell
        }
        self.tableView.dataSource = self.dataSource

        let request = NSFetchRequest<Clip>(entityName: "Clip")
        request.sortDescriptors = [NSSortDescriptor(key: "registeredDate", ascending: true)]
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
        let clip = NSEntityDescription.insertNewObject(forEntityName: "Clip",
                                                       into: self.container.viewContext) as! Clip
        clip.id = UUID()
        clip.registeredDate = Date()
        clip.updatedDate = Date()
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

        self.clips = snapshot.itemIdentifiers
            .compactMap { controller.managedObjectContext.object(with: $0) as? Clip }
            .compactMap { ClipModel(clip: $0) }
    }
}

