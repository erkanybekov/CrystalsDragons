//
//  GameEngine.swift
//  CrystalsDragons
//
//  Created by Erlan Kanybekov on 10/25/25.
//


class GameEngine {
    private var rooms: [[Room]]
    private var player: Player
    private let gridSize: Int
    
    var gameState: GameState = .playing
    var lastMessage: String = ""
    
    enum GameState {
        case setup
        case playing
        case won
        case lost
    }
    
    init(gridSize: Int) {
        self.gridSize = gridSize
        self.rooms = []
        self.player = Player(x: 0, y: 0, inventory: [], maxSteps: 100, currentSteps: 100, gold: 0)
        generateLabyrinth()
    }
    
    private func generateLabyrinth() {
        // Создаём сетку комнат
        rooms = (0..<gridSize).map { y in
            (0..<gridSize).map { x in
                Room(x: x, y: y)
            }
        }
        
        // Генерируем связный лабиринт с помощью DFS
        var visited = Set<String>()
        var stack: [(Int, Int)] = [(0, 0)]
        
        while !stack.isEmpty {
            let (x, y) = stack.removeLast()
            let key = "\(x),\(y)"
            
            if visited.contains(key) { continue }
            visited.insert(key)
            
            // Получаем доступных соседей
            var neighbors: [(Int, Int, Direction)] = []
            for dir in Direction.allCases {
                let nx = x + dir.offset.x
                let ny = y + dir.offset.y
                if nx >= 0 && nx < gridSize && ny >= 0 && ny < gridSize {
                    let nkey = "\(nx),\(ny)"
                    if !visited.contains(nkey) {
                        neighbors.append((nx, ny, dir))
                    }
                }
            }
            
            neighbors.shuffle()
            
            for (nx, ny, dir) in neighbors {
                let nkey = "\(nx),\(ny)"
                if !visited.contains(nkey) {
                    // Создаём связь между комнатами
                    rooms[y][x].doors.insert(dir)
                    let oppositeDir = oppositeDirection(dir)
                    rooms[ny][nx].doors.insert(oppositeDir)
                    stack.append((nx, ny))
                }
            }
        }
        
        // Добавляем дополнительные проходы для усложнения
        for _ in 0..<gridSize {
            let x = Int.random(in: 0..<gridSize)
            let y = Int.random(in: 0..<gridSize)
            if let dir = Direction.allCases.randomElement() {
                let nx = x + dir.offset.x
                let ny = y + dir.offset.y
                if nx >= 0 && nx < gridSize && ny >= 0 && ny < gridSize {
                    rooms[y][x].doors.insert(dir)
                    rooms[ny][nx].doors.insert(oppositeDirection(dir))
                }
            }
        }
        
        placeItems()
        placePlayer()
    }
    
    private func oppositeDirection(_ dir: Direction) -> Direction {
        switch dir {
        case .north: return .south
        case .south: return .north
        case .west: return .east
        case .east: return .west
        }
    }
    
    private func placeItems() {
        // Размещаем ключ и сундук в достижимых местах
        let reachable = getReachableRooms(from: (0, 0))
        guard reachable.count >= 2 else { return }
        
        let positions = reachable.shuffled()
        if positions.count >= 2 {
            rooms[positions[0].y][positions[0].x].items.append(Item(type: .key, goldAmount: nil))
            rooms[positions[1].y][positions[1].x].items.append(Item(type: .chest, goldAmount: nil))
        }
        
        // Добавляем дополнительные предметы
        for _ in 0..<min(3, gridSize) {
            if let pos = reachable.randomElement() {
                rooms[pos.y][pos.x].items.append(Item(type: .torchlight, goldAmount: nil))
            }
        }
        
        for _ in 0..<min(2, gridSize) {
            if let pos = reachable.randomElement() {
                rooms[pos.y][pos.x].items.append(Item(type: .food, goldAmount: nil))
            }
        }
        
        for _ in 0..<min(2, gridSize) {
            if let pos = reachable.randomElement() {
                rooms[pos.y][pos.x].items.append(Item(type: .sword, goldAmount: nil))
            }
        }
        
        // Золото
        for _ in 0..<min(4, gridSize * 2) {
            if let pos = reachable.randomElement() {
                let amount = Int.random(in: 50...500)
                rooms[pos.y][pos.x].items.append(Item(type: .gold, goldAmount: amount))
            }
        }
        
        // Тёмные комнаты
        for _ in 0..<min(gridSize / 2, 3) {
            if let pos = reachable.randomElement() {
                rooms[pos.y][pos.x].type = .dark
            }
        }
        
        // Монстры
        let monsterNames = ["Goblin", "Troll", "Orc", "Dragon", "Skeleton"]
        for _ in 0..<min(gridSize / 2, 4) {
            if let pos = reachable.randomElement() {
                rooms[pos.y][pos.x].hasMonster = true
                rooms[pos.y][pos.x].monsterName = monsterNames.randomElement()
            }
        }
    }
    
    private func placePlayer() {
        player.x = 0
        player.y = 0
        player.currentSteps = gridSize * gridSize * 3 // Достаточный лимит
        player.maxSteps = player.currentSteps
    }
    
    private func getReachableRooms(from start: (x: Int, y: Int)) -> [(x: Int, y: Int)] {
        var visited = Set<String>()
        var queue: [(Int, Int)] = [start]
        var result: [(x: Int, y: Int)] = []
        
        while !queue.isEmpty {
            let (x, y) = queue.removeFirst()
            let key = "\(x),\(y)"
            if visited.contains(key) { continue }
            visited.insert(key)
            result.append((x, y))
            
            for dir in rooms[y][x].doors {
                let nx = x + dir.offset.x
                let ny = y + dir.offset.y
                if !visited.contains("\(nx),\(ny)") {
                    queue.append((nx, ny))
                }
            }
        }
        
        return result
    }
    
    func getCurrentRoom() -> Room {
        rooms[player.y][player.x]
    }
    
    func getRoomDescription() -> String {
        let room = getCurrentRoom()
        
        // Проверка тёмной комнаты
        if room.type == .dark && !player.hasTorchlight && !room.isLit {
            return "Can't see anything in this dark place!"
        }
        
        var desc = "You are in the room [\(room.x),\(room.y)]. "
        desc += "There are \(room.doors.count) doors: "
        desc += room.doors.map { $0.rawValue }.sorted().joined(separator: ", ")
        desc += ". "
        
        if !room.items.isEmpty {
            desc += "Items in the room: "
            desc += room.items.map { $0.displayName }.joined(separator: ", ")
            desc += "."
        } else {
            desc += "No items in the room."
        }
        
        if room.hasMonster, let name = room.monsterName {
            desc += "\n⚠️ There is an evil \(name) in the room!"
        }
        
        return desc
    }
    
    func move(_ direction: Direction) -> String {
        let room = getCurrentRoom()
        
        // Проверка возможности движения в тёмной комнате
        if room.type == .dark && !player.hasTorchlight && !room.isLit {
            // В тёмной комнате можно только двигаться
        }
        
        guard room.doors.contains(direction) else {
            return "There is no door in that direction!"
        }
        
        let nx = player.x + direction.offset.x
        let ny = player.y + direction.offset.y
        
        player.x = nx
        player.y = ny
        player.currentSteps -= 1
        
        if player.currentSteps <= 0 {
            gameState = .lost
            return "You have died from hunger in the dark dungeon..."
        }
        
        return "Moved \(direction.fullName). Steps remaining: \(player.currentSteps)"
    }
    
    func getItem(_ itemName: String) -> String {
        let room = getCurrentRoom()
        
        // Проверка тёмной комнаты
        if room.type == .dark && !player.hasTorchlight && !room.isLit {
            return "Can't see anything in this dark place!"
        }
        
        guard let index = rooms[player.y][player.x].items.firstIndex(where: { $0.type.rawValue == itemName }) else {
            return "No such item in this room!"
        }
        
        let item = rooms[player.y][player.x].items[index]
        
        if item.type == .gold {
            let amount = item.goldAmount ?? 0
            player.gold += amount
            rooms[player.y][player.x].items.remove(at: index)
            return "Picked up \(amount) coins! Total gold: \(player.gold)"
        }
        
        guard item.type.isPickable else {
            return "You can't pick up the chest!"
        }
        
        player.inventory.append(item)
        rooms[player.y][player.x].items.remove(at: index)
        
        return "Picked up \(item.type.rawValue)."
    }
    
    func dropItem(_ itemName: String) -> String {
        guard let index = player.inventory.firstIndex(where: { $0.type.rawValue == itemName }) else {
            return "You don't have this item!"
        }
        
        let item = player.inventory.remove(at: index)
        rooms[player.y][player.x].items.append(item)
        
        // Если бросили факел в тёмной комнате - она остаётся освещённой
        if item.type == .torchlight && rooms[player.y][player.x].type == .dark {
            rooms[player.y][player.x].isLit = true
        }
        
        return "Dropped \(item.type.rawValue)."
    }
    
    func openChest() -> String {
        let room = getCurrentRoom()
        
        if room.type == .dark && !player.hasTorchlight && !room.isLit {
            return "Can't see anything in this dark place!"
        }
        
        guard room.items.contains(where: { $0.type == .chest }) else {
            return "There is no chest in this room!"
        }
        
        guard player.hasKey else {
            return "You need a key to open the chest!"
        }
        
        gameState = .won
        return "🎉 You opened the chest and found the Holy Grail! YOU WIN!"
    }
    
    func eat(_ itemName: String) -> String {
        guard let index = player.inventory.firstIndex(where: { $0.type.rawValue == itemName && $0.type == .food }) else {
            return "You don't have this food!"
        }
        
        player.inventory.remove(at: index)
        let bonus = 20
        player.currentSteps += bonus
        player.maxSteps += bonus
        
        return "Ate food. Gained \(bonus) health! Current health: \(player.currentSteps)"
    }
    
    func fight() -> String {
        var room = getCurrentRoom()
        
        guard room.hasMonster else {
            return "There is no monster to fight!"
        }
        
        guard player.hasSword else {
            return "You need a sword to fight!"
        }
        
        let outcome = Int.random(in: 1...3)
        
        switch outcome {
        case 1:
            // Неудача - теряем 10% здоровья и откидывает назад
            player.reduceHealth(by: 0.1)
            return "The monster击败了 you! Lost 10% health. Thrown back!"
        case 2:
            // Успех с уроном
            player.reduceHealth(by: 0.1)
            rooms[player.y][player.x].hasMonster = false
            rooms[player.y][player.x].monsterName = nil
            return "You defeated the monster but got injured! Lost 10% health."
        case 3:
            // Полный успех
            rooms[player.y][player.x].hasMonster = false
            rooms[player.y][player.x].monsterName = nil
            return "You defeated the monster without injury! Victory!"
        default:
            return ""
        }
    }
    
    func getPlayerInfo() -> String {
        var info = "Health: \(player.currentSteps)/\(player.maxSteps) | Gold: \(player.gold) coins"
        if !player.inventory.isEmpty {
            info += "\nInventory: " + player.inventory.map { $0.type.rawValue }.joined(separator: ", ")
        }
        return info
    }
}