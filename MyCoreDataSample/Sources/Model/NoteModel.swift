//
//  NoteModel.swift
//  MyCoreDataSample
//
//  Created by Tasuku Tozawa on 2020/12/01.
//

import Foundation

struct NoteModel {
    let id: UUID
    let title: String
    let createdAt: Date
    let updatedAt: Date
    let tags: [TagModel]
}

extension NoteModel: Hashable {}

extension Note {
    func map(to: NoteModel.Type) -> NoteModel? {
        guard
            let id = self.id,
            let createdAt = self.createdAt,
            let updatedAt = self.updatedAt else {
            return nil
        }

        let tags = self.tags?.allObjects
            .compactMap { $0 as? Tag }
            .compactMap { $0.map(to: TagModel.self) } ?? []

        return .init(
            id: id,
            title: title ?? "",
            createdAt: createdAt,
            updatedAt: updatedAt,
            tags: tags
        )
    }
}
