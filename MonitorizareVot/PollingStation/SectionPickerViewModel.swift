//
//  SectionPickerViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 01/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

enum SectionPickerViewModelError: Error {
    case genericError(reason: String)
    
    var localizedDescription: String {
        switch self {
        case .genericError(let reason): return reason
        }
    }
}

class SectionPickerViewModel: NSObject {
    
    var countyCode: String? {
        didSet {
            sectionId = nil
            onStateChanged?()
        }
    }
    
    var sectionId: Int? {
        didSet {
            onStateChanged?()
        }
    }
    
    var canContinue: Bool {
        return countyCode != nil && sectionId != nil
    }
    
    var isSectionNumberCorrect: Bool {
        return sectionId != nil && maximumStationNumber != nil && sectionId! <= maximumStationNumber!
    }
    
    var selectedCountyName: String? {
        guard let code = countyCode else { return nil }
        return getPollingStation(byCounty: code)?.name.capitalized
    }
    
    /// Be notified when the API download state has changed
    var onDownloadStateChanged: (() -> Void)?
    
    /// Be notified when the API save state has changed
    var onSaveStateChanged: (() -> Void)?
    
    /// Be notified whenever the model data changes so you can update the interface with fresh data
    var onStateChanged: (() -> Void)?
    
    fileprivate(set) var availableCounties: [PollingStationResponse] = []
    
    var maximumStationNumber: Int? {
        guard let selectedCounty = countyCode else { return nil }
        return getPollingStation(byCounty: selectedCounty)?.limit
    }
    
    fileprivate(set) var isDownloading: Bool = false {
        didSet {
            onDownloadStateChanged?()
        }
    }
    
    fileprivate(set) var isSaving: Bool = false {
        didSet {
            onSaveStateChanged?()
        }
    }
    
    override init() {
        if let currentSection = DB.shared.currentSectionInfo() {
            countyCode = currentSection.countyCode
            sectionId = Int(currentSection.sectionId)
        }
        super.init()
    }
    
    func fetchPollingStations(then callback: @escaping (APIError?) -> Void) {
        isDownloading = true
        APIManager.shared.fetchPollingStations { (stations, error) in
            if let stations = stations {
                self.availableCounties = stations
                LocalStorage.shared.pollingStations = stations
            }
            callback(error)
            self.isDownloading = false
        }
    }
    
    func availableSectionIds(inCounty county: String) -> [Int] {
        if let countyData = getPollingStation(byCounty: county) {
            return Array(1...countyData.limit)
        }
        return []
    }
    
    fileprivate func getPollingStation(byCounty county: String) -> PollingStationResponse? {
        return availableCounties.filter { $0.code == county }.first
    }
    
    func persist(then callback: @escaping (SectionPickerViewModelError?) -> Void) {
        guard let county = countyCode,
            let sectionId = sectionId else {
            callback(.genericError(reason: "Invalid section data provided"))
            return
        }
        let _ = DB.shared.sectionInfo(for: county, sectionId: sectionId)
        PreferencesManager.shared.county = county
        PreferencesManager.shared.section = sectionId
        if let countyName = selectedCountyName {
            PreferencesManager.shared.sectionName = "Station".localized + " \(sectionId) \(countyName)"
        }
        callback(nil)
    }
    
}
