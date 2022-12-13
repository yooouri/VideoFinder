//
//  Video.swift
//  VideoFinder
//
//  Created by yuri on 2022/10/26.
//

import Foundation


struct Meta: Codable {
    let total_count: Int
    let pageable_count: Int
    let is_end: Bool
}


struct Vclip: Codable {
    let title: String
    let url: String
    let datetime: String //date?
    let play_time: Int
    let thumbnail: String
    let author: String
}

struct ResultData: Codable {
    let meta: Meta
    let documents: [Vclip]
}

