//
//  GameViewModel.swift
//  CrystalsDragons
//
//  Created by Erlan Kanybekov on 10/25/25.
//

import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published var consoleOutput: [String] = []
    @Published var currentInput: String = ""
    @Published var isGameStarted: Bool = false
    @Published var gridSize: Int = 5
    
    private var engine: GameEngine?
    
    func startGame() {
        engine = GameEngine(gridSize: gridSize)
        isGameStarted = true
        consoleOutput = [
            "=== CRYSTALS AND DRAGONS ===",
            "Welcome, brave adventurer!",
            "Find the key and chest to claim the Holy Grail!",
            "Rookie? type the <help> command!",
            "",
            engine?.getRoomDescription() ?? "",
            "",
            engine?.getPlayerInfo() ?? ""
        ]
    }
    
    func processCommand(_ command: String) {
        guard let engine = engine else { return }
        
        let cmd = command.trimmingCharacters(in: .whitespaces).lowercased()
        consoleOutput.append("> \(command)")
        
        let result = executeCommand(cmd, engine: engine)
        consoleOutput.append(result)
        
        handleGameState(engine: engine)
        
        if isMovementCommand(cmd) {
            showRoomInfo(engine: engine)
        }
    }
    
    private func executeCommand(_ cmd: String, engine: GameEngine) -> String {
        // Проверка движения
        if let direction = parseDirection(cmd) {
            return engine.move(direction)
        }
        
        // Команды с аргументами
        if cmd.hasPrefix("get ") {
            return engine.getItem(String(cmd.dropFirst(4)))
        }
        if cmd.hasPrefix("drop ") {
            return engine.dropItem(String(cmd.dropFirst(5)))
        }
        if cmd.hasPrefix("eat ") {
            return engine.eat(String(cmd.dropFirst(4)))
        }
        
        // команды
        switch cmd {
        case "open", "open chest":
            return engine.openChest()
        case "fight":
            return engine.fight()
        case "help":
            return helpText
        default:
            return "Unknown command. Type 'help' for commands."
        }
    }
    
    private func parseDirection(_ cmd: String) -> Direction? {
        switch cmd {
        case "n", "north": return .north
        case "s", "south": return .south
        case "w", "west": return .west
        case "e", "east": return .east
        default: return nil
        }
    }
    
    private func isMovementCommand(_ cmd: String) -> Bool {
        parseDirection(cmd) != nil
    }
    
    private func handleGameState(engine: GameEngine) {
        guard engine.gameState != .playing else { return }
        
        consoleOutput.append("")
        consoleOutput.append(engine.gameState == .won ? "🏆 VICTORY! 🏆" : "💀 GAME OVER 💀")
    }
    
    private func showRoomInfo(engine: GameEngine) {
        consoleOutput.append("")
        consoleOutput.append(engine.getRoomDescription())
        consoleOutput.append("")
        consoleOutput.append(engine.getPlayerInfo())
    }
    
    private var helpText: String {
        """
        Commands:
        N/S/W/E - Move North/South/West/East
        
        get [item] - Pick up item
        
        drop [item] - Drop item
        
        open - Open chest (need key)
        
        eat [item] - Eat food
        
        fight - Fight monster (need sword)
        
        help - Show this help
        """
    }
}
