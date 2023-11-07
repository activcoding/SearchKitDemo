//
//  SearchManger.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 31.10.23.
//

import Foundation

struct FileViewModel: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
}