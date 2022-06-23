//
// Copyright © 2022 arvinq. All rights reserved.
//
	

import Foundation

struct PersistenceManager {
    
    /**
     * Upon application start, we check whether we have some data stored in our UserDefaults, if none, we preload data from our region propertyList.
     */
    static func preloadRegions(completion: @escaping (FSError?) -> Void) {
        retrieveRegions { result in
            switch result {
            case .success(let regionsObjArray):
                guard regionsObjArray.isEmpty else { return }
                
                var regionsToSave: [Region] = []
                
                // get the url where the file sits and use this to preload our table
                guard let preloadRegionUrl = Bundle.main.url(forResource: Constant.preloadedRegions, withExtension: "plist"),
                      let regionsStrArray = NSArray(contentsOf: preloadRegionUrl) as? [String] else {
                    completion(.noFileFound)
                    return
                }
                
                // for each retrieved region in our property list, we create an instance of the Region
                regionsStrArray.forEach { regionName in
                    let region = Region(name: regionName)
                    regionsToSave.append(region)
                }
                
                // And save the regions into our UserDefaults
                completion(save(regions: regionsToSave))
                
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    /**
     * Retrieving the whole region list from our userDefaults and passing it to the calling functions
     */
    static func retrieveRegions(completion: @escaping (Result<[Region], FSError>) -> Void) {
        guard let regionsData = UserDefaults.standard.object(forKey: Key.regions) as? Data else {
            completion(.success([]))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let regions = try decoder.decode([Region].self, from: regionsData)
            completion(.success(regions))
        } catch {
            completion(.failure(.invalidData))
        }
    }
    
    /**
     * Saving the region into Userdefaults tagging it by the region's key
     */
    static func save(regions: [Region]) -> FSError? {
        do {
            let regionsData = try JSONEncoder().encode(regions)
            UserDefaults.standard.set(regionsData, forKey: Key.regions)
        } catch {
            return .saveError
        }
        
        return nil
    }
}
