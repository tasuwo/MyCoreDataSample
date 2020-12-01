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
        return .init(
            id: id,
            title: title ?? "",
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
