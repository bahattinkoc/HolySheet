//
//  Array+Extension.swift
//  conal
//
//  Created by BAHATTIN KOC on 12/10/24.
//

extension Array where Element: (Comparable & SignedNumeric) {
    /// Retrieve nearest elements according to the given value.
    func nearest(to value: Element) -> (Element)? {
        self.enumerated().min(by: {
            abs($0.element - value) < abs($1.element - value)
        })?.element
    }
}
