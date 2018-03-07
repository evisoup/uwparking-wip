//
//  ShortcutIdentifier.swift
//  UWaterloo Parking
//
//  Created by 刘恒邑 on 2018/3/6.
//  Copyright © 2018年 Hengyi Liu. All rights reserved.
//

import Foundation

enum ShortcutIdentifier: String {
    case lots
    case pin

    var index: Int {
        switch self {
        case .lots:
            return 0
        case .pin:
            return 2
        }
    }
}
