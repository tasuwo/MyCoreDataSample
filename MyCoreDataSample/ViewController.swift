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

    enum Section {
        case main
    }

    struct Clip: Equatable, Hashable {
        let id: UUID
        let descriptionText: String?
        let isHidden: Bool
        let registeredDate: Date
        let updatedDate: Date
        let tags: [Tag]

        init(id: UUID) {
            self.id = id
            self.descriptionText = nil
            self.isHidden = false
            self.registeredDate = Date(timeIntervalSince1970: 0)
            self.updatedDate = Date(timeIntervalSince1970: 0)
            self.tags = []
        }
    }

    struct Tag: Equatable, Hashable {
        let id: UUID
        let name: String
        let clips: Clip
    }

    @IBOutlet weak var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Section, Clip>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.dataSource = UITableViewDiffableDataSource<Section, Clip>(tableView: self.tableView) {
            (tableView: UITableView, indexPath: IndexPath, itemIdentifier: Clip) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else { return nil }
            cell.textLabel?.text = itemIdentifier.id.uuidString
            return cell
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        var snapshot = NSDiffableDataSourceSnapshot<Section, Clip>()
        snapshot.appendSections([.main])
        snapshot.appendItems(
            [
                .init(id: UUID()),
                .init(id: UUID()),
                .init(id: UUID())
            ]
        )
        self.dataSource.apply(snapshot)
    }
}

