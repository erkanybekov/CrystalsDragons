//
//  Player.swift
//  CrystalsDragons
//
//  Created by Erlan Kanybekov on 10/25/25.
//


struct Player {
    var x: Int
    var y: Int
    var inventory: [Item]
    var maxSteps: Int
    var currentSteps: Int
    var gold: Int
    
    var hasKey: Bool {
        inventory.contains { $0.type == .key }
    }
    
    var hasTorchlight: Bool {
        inventory.contains { $0.type == .torchlight }
    }
    
    var hasSword: Bool {
        inventory.contains { $0.type == .sword }
    }
    
    mutating func reduceHealth(by percent: Double) {
        let reduction = Int(Double(maxSteps) * percent)
        currentSteps = max(0, currentSteps - reduction)
    }
}
