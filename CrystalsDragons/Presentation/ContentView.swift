//
//  ContentView.swift
//  CrystalsDragons
//
//  Created by Erlan Kanybekov on 10/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.isGameStarted {
                setupView
            } else {
                gameView
            }
        }
    }
    
    private var setupView: some View {
        VStack(spacing: 20) {
            title
            
            gridConfig
            
            Button(action: {
                viewModel.startGame()
            }) {
                Text("START GAME")
                    .gameButtonStyle()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    @ViewBuilder
    private var title: some View {
        Text("CRYSTALS AND DRAGONS")
            .font(.system(size: 32, weight: .bold, design: .monospaced))
            .foregroundColor(.cyan)
        
        Text("⚔️ 🗝️ 📦 🏆")
            .font(.system(size: 40))
    }
    
    // MARK: Grid Configuration
    private var gridConfig: some View {
        VStack(spacing: 10) {
            Text("Grid Size: \(viewModel.gridSize)x\(viewModel.gridSize)")
                .font(.system(size: 18, design: .monospaced))
                .foregroundColor(Color(#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)))
            
            Stepper("", value: $viewModel.gridSize, in: 3...10)
                .stepperStyle()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
    
    // MARK: GAME VIEW
    private var gameView: some View {
        VStack(spacing: 0) {
            // Console output
            consoleOutput
            
            // Input area
            inputArea
        }
    }
    
    private var consoleOutput: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(viewModel.consoleOutput.enumerated()), id: \.offset) { index, line in
                        Text(line)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(getLineColor(line))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id(index)
                    }
                }
                .padding()
            }
            .background(Color.black)
            .onChange(of: viewModel.consoleOutput.count) { _ in
                withAnimation {
                    proxy.scrollTo(viewModel.consoleOutput.count - 1, anchor: .bottom)
                }
            }
        }
    }
    
    private var inputArea: some View {
        HStack(spacing: 10) {
            Text(">")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.green)
            
            TextField("Enter command", text: $viewModel.currentInput)
                .textFieldStyle()
                .onSubmit {
                    if !viewModel.currentInput.isEmpty {
                        viewModel.processCommand(viewModel.currentInput)
                        viewModel.currentInput = ""
                    }
                }
            
            Button(action: {
                if !viewModel.currentInput.isEmpty {
                    viewModel.processCommand(viewModel.currentInput)
                    viewModel.currentInput = ""
                }
            }) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
    
    private func getLineColor(_ line: String) -> Color {
        if line.hasPrefix(">") {
            return .cyan
        } else if line.contains("WIN") || line.contains("Victory") || line.contains("🎉") {
            return .green
        } else if line.contains("GAME OVER") || line.contains("died") || line.contains("💀") {
            return .red
        } else if line.contains("⚠️") || line.contains("evil") {
            return .orange
        } else if line.contains("Health:") || line.contains("Inventory:") {
            return .yellow
        } else if line.hasPrefix("===") {
            return .cyan
        } else {
            return .white
        }
    }
}

// MARK: Helpers

extension View {
    func gameButtonStyle() -> some View {
        self.font(.system(size: 20, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
            .padding(.horizontal, 40)
            .padding(.vertical, 15)
            .background(Color.green)
            .cornerRadius(10)
    }
    
    func stepperStyle() -> some View {
        self.labelsHidden()
            .frame(width: 100)
            .foregroundColor(Color(#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)))
    }
    
    func textFieldStyle() -> some View {
        self.font(.system(size: 16, design: .monospaced))
            .textFieldStyle(PlainTextFieldStyle())
            .foregroundColor(.black)
            .autocapitalization(.none)
            .disableAutocorrection(true)

    }
}

#Preview {
    ContentView()
}
