//
//  GithubServiceMock.swift
//  RepoSearcher
//
//  Created by Andriy P on 7/12/17.
//  Copyright © 2017 PowerMobileWeb Team. All rights reserved.
//

@testable import RepoSearcher
import RxSwift

class GithubServiceMock: GithubService {

    var languageListReturnValue: Observable<[String]> = .empty()
    override func getLanguageList() -> Observable<[String]> {
        return languageListReturnValue
    }

    var repositoriesLanguageArgument: String!
    var repositoriesReturnValue: Observable<[Repository]> = .empty()
    override func getMostPopularRepositories(byLanguage language: String) -> Observable<[Repository]> {
        repositoriesLanguageArgument = language
        return repositoriesReturnValue
    }
}
