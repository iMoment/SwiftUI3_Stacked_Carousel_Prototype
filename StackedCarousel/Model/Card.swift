//
//  Card.swift
//  StackedCarousel
//
//  Created by Stanley Pan on 2022/02/20.
//

import SwiftUI

struct Card: Identifiable {
    var id: String = UUID().uuidString
    var cardColor: Color
    var date: String = ""
    var title: String
}
