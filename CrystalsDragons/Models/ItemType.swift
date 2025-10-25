//
//  ItemType.swift
//  CrystalsDragons
//
//  Created by Erlan Kanybekov on 10/25/25.
//
import Foundation

enum ItemType: String {
    case key = "key"
    case chest = "chest"
    case torchlight = "torchlight"
    case food = "food"
    case sword = "sword"
    case gold = "gold"
    
    var isPickable: Bool {
        self != .chest
    }
}

struct Item: Identifiable, Equatable {
    let id = UUID()
    let type: ItemType
    var goldAmount: Int?
    
    var displayName: String {
        if type == .gold, let amount = goldAmount {
            return "gold (\(amount) coins)"
        }
        return type.rawValue
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}
