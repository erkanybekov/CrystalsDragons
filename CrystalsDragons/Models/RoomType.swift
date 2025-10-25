//
//  RoomType.swift
//  CrystalsDragons
//
//  Created by Erlan Kanybekov on 10/25/25.
//

import Foundation

enum RoomType {
    case normal
    case dark
}

struct Room {
    let x: Int
    let y: Int
    var doors: Set<Direction>
    var items: [Item]
    var type: RoomType
    var hasMonster: Bool
    var monsterName: String?
    var isLit: Bool // для тёмных комнат с факелом
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
        self.doors = []
        self.items = []
        self.type = .normal
        self.hasMonster = false
        self.monsterName = nil
        self.isLit = false
    }
}
