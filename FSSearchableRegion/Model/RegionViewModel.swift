//
// Copyright © 2022 arvinq. All rights reserved.
//
	

import Foundation

class RegionViewModel {
    let name: String
    var isSelected: Bool = false
    
    init(region: Region) {
        self.name = region.name
    }
}
