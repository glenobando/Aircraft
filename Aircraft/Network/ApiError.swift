//
//  ApiError.swift
//  ModuloIOSProyectoFinal
//
//  Created by Admin on 6/18/21.
//

import Foundation


enum ApiError: Error {
    case requestFailed(description: String)
    case jsonConversionFailure(description: String)
    case responseInvalid(description: String)
    case invalidData
    case jsonParsingError
}
