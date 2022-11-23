//
//  ImageResponse.swift
//  NASA Image Loader
//
//  Created by Shreekrishna on 23/11/22.
//

import Foundation

struct ImageResponse: Codable {
    let date: String?
    let explanation: String?
    let media_type: String?
    let service_version: String?
    let title: String?
    let url: String?
}
