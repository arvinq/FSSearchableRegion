//
// Copyright © 2022 arvinq. All rights reserved.
//
	

import UIKit

class ViewModelManager {
    // properties that triggers binding and updates our views
    var alertMessage: String? {
        didSet { self.presentAlert?() }
    }
    
    var regionViewModels: [RegionViewModel] = [] {
        didSet {
            self.regionViewModels.sort { $0.name < $1.name }
            self.reloadRegionsTable?()
        }
    }
    
    var filteredRegionViewModels: [RegionViewModel] = [] {
        didSet {
            self.filteredRegionViewModels.sort { $0.name < $1.name }
            self.reloadRegionsTable?()
        }
    }
    
    var isLoading: Bool = false {
        didSet { self.animateLoadView?() }
    }
    
    // bindings, implementation of the bindings are found in the viewController
    var presentAlert: (()->())?
    var reloadRegionsTable: (()->())?
    var animateLoadView: (()->())?
        
    /**
     * first entry point that retrieves the data to be displayed and trigger binding to populate our tableView
     */
    func getRegions() {
        self.isLoading = true
        PersistenceManager.retrieveRegions { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let regions):
                var regionViewModels = [RegionViewModel]()
                regionViewModels.append(contentsOf: regions.map { RegionViewModel(region: $0) })
                self.regionViewModels = regionViewModels // will trigger the reload
            case .failure(let error):
                self.alertMessage = error.rawValue
            }
        }
    }
    
    /// Returns an individual view model at a given index in the array.
    func getRegionViewModel(onIndex index: Int, isSearching: Bool) -> RegionViewModel {
        return isSearching ? filteredRegionViewModels[index] : regionViewModels[index]
    }
    
    ///  Returns an individual view model with a given name property of the region view model
    func getRegionViewModel(withName name: String, isSearching: Bool) -> RegionViewModel? {
        let regionViewModels = getRegionViewModels(isSearching: isSearching)
        return regionViewModels.filter { $0.name == name }.first
    }
    
    /// Returns our viewModel list based on the app's status if search is in progress or not.
    func getRegionViewModels(isSearching isSeaching: Bool) -> [RegionViewModel] {
        return isSeaching ? filteredRegionViewModels : regionViewModels
    }
    
    /// Configures the selected state of each of the view models in filtered and original regions list.
    func configureSelectionState(onIndex index: Int, isSearching: Bool) {
        if isSearching {
            if filteredRegionViewModels[index].isSelected {
                // if same item is reselected, we reset our list deselecting the item and just return
                filteredRegionViewModels.forEach{ $0.isSelected = false }
                regionViewModels.forEach { $0.isSelected = false }
                self.reloadRegionsTable?()
                return
            }
            
            // reset our lists
            filteredRegionViewModels.forEach{ $0.isSelected = false }
            regionViewModels.forEach { $0.isSelected = false }
            
            // set state on selected region and reload the table
            filteredRegionViewModels[index].isSelected = true
            self.reloadRegionsTable?()
            
            // also set state on the other list so that selected state reflects on that list as well
            let selectedRegionName = filteredRegionViewModels[index].name
            let otherSourceIndex = regionViewModels.firstIndex { $0.name == selectedRegionName }!
            regionViewModels[otherSourceIndex].isSelected = true
            
        } else {
            if regionViewModels[index].isSelected {
                // if same item is reselected, we reset our list, deselecting the item and just return
                regionViewModels.forEach { $0.isSelected = false }
                self.reloadRegionsTable?()
                return
            }
            
            // reset our main list, set state and apply it on other list to reflect the state
            regionViewModels.forEach { $0.isSelected = false }
            regionViewModels[index].isSelected = true
            setInitialFilteredRegions()
        }
    }
    
    /// Filter the main list via the searched regionName and trigger the tableView update
    func filterRegion(onName regionName: String) {
        filteredRegionViewModels = regionViewModels.filter {
            $0.name.lowercased().contains(regionName.lowercased())
        }
    }
    
    /// Setting the initial data for filteredRegionViewModels
    func setInitialFilteredRegions() {
        filteredRegionViewModels = regionViewModels
    }
}
