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

    private var clips: [Clip] = [] {
        didSet {
            var snapshot = NSDiffableDataSourceSnapshot<Section, Clip>()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.clips)
            self.dataSource.apply(snapshot)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.didTapAdd(_:)))

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.dataSource = UITableViewDiffableDataSource<Section, Clip>(tableView: self.tableView) {
            (tableView: UITableView, indexPath: IndexPath, itemIdentifier: Clip) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else { return nil }
            cell.textLabel?.text = itemIdentifier.id.uuidString
            return cell
        }
    }

    @objc
    func didTapAdd(_ sender: UIBarButtonItem) {
        self.clips.append(.init(id: UUID()))
    }
}

