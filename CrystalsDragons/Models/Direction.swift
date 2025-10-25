//
//  Direction.swift
//  CrystalsDragons
//
//  Created by Erlan Kanybekov on 10/25/25.
//

enum Direction: String, CaseIterable {
    case north = "N"
    case south = "S"
    case west = "W"
    case east = "E"
    
    var fullName: String {
        switch self {
        case .north: return "North"
        case .south: return "South"
        case .west: return "West"
        case .east: return "East"
        }
    }
    
    /// n - down;
    /// s - up;
    /// w - left
    /// e - right
    var offset: (x: Int, y: Int) {
        switch self {
        case .north: return (0, -1)
        case .south: return (0, 1)
        case .west: return (-1, 0)
        case .east: return (1, 0)
        }
    }
}
