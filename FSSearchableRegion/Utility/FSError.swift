//
// Copyright © 2022 arvinq. All rights reserved.
//
	

import Foundation

/// Custom error list that can be consumed within the app to return a meaningful message on error caught
enum FSError: String, Error {
    case unableToComplete = "Unable to complete your request. Please try again later."
    case invalidData      = "The data retrieved is either corrupt or invalid. Please try again."
    case noFileFound      = "No data file found. Please contact the administrator."
    case unableToDecode   = "Unable to decode the data. Please check if you're decoding your data correctly."
    case unableToEncode   = "Unable to encode the data. Please check if the data is being encoded correctly."
    case saveError        = "Unable to save data. Please try again."
}
