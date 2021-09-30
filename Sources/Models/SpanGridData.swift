//
//  SpanGridData.swift
//  SpanGrid
//
//  Created by James Sherlock on 27/09/2021.
//

import SwiftUI

/// Wraps the client-provided data with extra information allowing for easier calculations of row and column positioning.
internal struct SpanGridData<Data: Identifiable>: Identifiable {
    
    /// The index of this cell within the grid where `0` is the first item, `1` is the second item and so on.
    let cellIndex: Int
    
    /// The underlying piece of grid data
    let data: Data
    
    /// Maps the underlying data identifier to maintain protocol conformance.
    var id: Data.ID {
        data.id
    }
    
}
