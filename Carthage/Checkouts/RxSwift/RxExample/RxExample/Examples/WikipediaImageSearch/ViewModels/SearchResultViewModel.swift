//
//  SearchResultViewModel.swift
//  RxExample
//
//  Created by PowerMobile Team on 4/3/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class SearchResultViewModel {
    let searchResult: WikipediaSearchResult

    var title: Driver<String>
    var imageURLs: Driver<[URL]>

    let API = DefaultWikipediaAPI.sharedAPI
    let $: Dependencies = Dependencies.sharedDependencies

    init(searchResult: WikipediaSearchResult) {
        self.searchResult = searchResult

        self.title = Driver.never()
        self.imageURLs = Driver.never()

        let URLs = configureImageURLs()

        self.imageURLs = URLs.asDriver(onErrorJustReturn: [])
        self.title = configureTitle(URLs).asDriver(onErrorJustReturn: "Error during fetching")
    }

    // private methods

    func configureTitle(_ imageURLs: Observable<[URL]>) -> Observable<String> {
        let searchResult = self.searchResult

        let loadingValue: [URL]? = nil

        return imageURLs
            .map(Optional.init)
            .startWith(loadingValue)
            .map { URLs in
                if let URLs = URLs {
                    return "\(searchResult.title) (\(URLs.count) pictures)"
                }
                else {
                    return "\(searchResult.title) (loading…)"
                }
            }
            .retryOnBecomesReachable("⚠️ Service offline ⚠️", reachabilityService: $.reachabilityService)
    }

    func configureImageURLs() -> Observable<[URL]> {
        let searchResult = self.searchResult
        return API.articleContent(searchResult)
            .observeOn($.backgroundWorkScheduler)
            .map { page in
                do {
                    return try parseImageURLsfromHTMLSuitableForDisplay(page.text as NSString)
                } catch {
                    return []
                }
            }
            .shareReplayLatestWhileConnected()
    }
}
