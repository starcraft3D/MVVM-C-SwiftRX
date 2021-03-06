//
//  RepositoryViewModel.swift
//  RepoSearcher
//
//  Created by Andriy P on 6/29/17.
//  Copyright © 2017 PowerMobile Team. All rights reserved.
//

import Foundation

class RepositoryViewModel {
    let name: String
    let description: String
    let starsCountText: String
    let url: URL

    init(repository: Repository) {
        self.name = "\(repository.fullName)"
        self.description = repository.description
        self.starsCountText = "⭐️ \(repository.starsCount)"
        self.url = URL(string: repository.url)!
    }
}
