//
// Copyright © 2022 arvinq. All rights reserved.
//
	

import UIKit

/// Constant value representing string used in the app
enum Constant {
    static let preloadedRegions = "region"
    static let searchPlaceholder = ""
}

/// Key constant that will be used in the app
enum Key {
    static let regions = "regions"
}

/// Alert button texts
enum AlertButton {
    static let okay = "Okay"
    static let cancel = "Cancel"
}

/// App's page view names
enum ViewTitle {
    static let main = "Select region"
    static let error = "Error"
    static let alert = "Regions"
}

/// Constant values to be used for animations
enum Animation {
    static let duration: CGFloat = 0.35
}

/// Easy access values to control the alpha properties for the UIElements in the app
enum Alpha {
    static let none: CGFloat       = 0.0
    static let weakFade: CGFloat   = 0.3
    static let mid: CGFloat        = 0.5
    static let strongFade: CGFloat = 0.8
    static let solid: CGFloat      = 1.0
}

/// Will contain SFSymbols images for easy access instead of keying in the whole system name
enum SFSymbols {
    static let globe = UIImage(systemName: "globe.asia.australia.fill")
    static let back  = UIImage(systemName: "chevron.backward")
}

/// Constant values that represent s the spaces used in the app
enum Space {
    static let padding: CGFloat         = 20.0
    static let margin: CGFloat          = 60.0
    static let adjacent: CGFloat        = 16.0
}

/// Constant values for representing view sizes in the app
enum Size {
    static let globeHeight: CGFloat = 25.0
    static let fontSize: CGFloat = 16.0
    static let keyboardHeight: CGFloat = 310.0
}
