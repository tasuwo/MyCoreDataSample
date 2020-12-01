//
//  TagModel.swift
//  MyCoreDataSample
//
//  Created by Tasuku Tozawa on 2020/12/01.
//

import Foundation

struct TagModel {
    let id: UUID
    let name: String
}

extension TagModel: Hashable {}

extension Tag {
    func map(to: TagModel.Type) -> TagModel? {
        guard let id = self.id else { return nil }
        return .init(id: id, name: self.name ?? "")
    }
}
