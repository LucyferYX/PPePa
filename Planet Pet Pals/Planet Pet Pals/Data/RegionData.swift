//
//  RegionData.swift
//  Planet Pet Pals
//
//  Created by Liene on 27/11/2023.
//

import Foundation

var regions: [String: ((Double, Double), (Double, Double))] {
    [
        NSLocalizedString("Latvia", comment: ""): ((56.0, 21.0), (58.0, 28.0)),
        NSLocalizedString("Europe", comment: ""): ((50.0, 10.0), (20.0, 60.0)),
        NSLocalizedString("North America", comment: ""): ((45.0, -100.0), (110.0, 140.0)),
        NSLocalizedString("Central America", comment: ""): ((15.0, -85.0), (20.0, 40.0)),
        NSLocalizedString("South America", comment: ""): ((-15.0, -60.0), (70.0, 110.0)),
        NSLocalizedString("Africa", comment: ""): ((10.0, 20.0), (70.0, 70.0)),
        NSLocalizedString("Middle East", comment: ""): ((30.0, 45.0), (20.0, 40.0)),
        NSLocalizedString("Central Asia", comment: ""): ((45.0, 75.0), (20.0, 40.0)),
        NSLocalizedString("South Asia", comment: ""): ((20.0, 80.0), (20.0, 40.0)),
        NSLocalizedString("East and Southeast Asia", comment: ""): ((20.0, 110.0), (30.0, 70.0)),
        NSLocalizedString("Australia and Oceania", comment: ""): ((-25.0, 135.0), (50.0, 70.0)),
        NSLocalizedString("Antarctica", comment: ""): ((-80.0, 0.0), (20.0, 360.0))
    ]
}
