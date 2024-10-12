//
//  HolySheetConfiguration.swift
//  HolySheet
//
//  Created by BAHATTIN KOC on 13.10.2024.
//

import UIKit

public struct HolySheetConfiguration {
    public var radius: CGFloat
    public var backgroundColor: UIColor

    public init(radius: CGFloat = 56.0, backgroundColor: UIColor = .white) {
        self.radius = radius
        self.backgroundColor = backgroundColor
    }
}
