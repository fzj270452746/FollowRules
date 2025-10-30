//
//  ViewModelPengaturan.swift
//  FollowRules
//
//  Settings Screen ViewModel
//

import Foundation
import Combine

// MARK: - ViewModel Pengaturan (Settings ViewModel)
class ViewModelPengaturan: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var versiAplikasi: String = "1.0.0"
    @Published private(set) var pesanKonfirmasi: String?
    @Published private(set) var sedangMemproses: Bool = false
    
    // MARK: - Dependencies
    private let repositoriSkor: RepositoriSkor
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(repositoriSkor: RepositoriSkor) {
        self.repositoriSkor = repositoriSkor
        muatInformasiAplikasi()
    }
    
    // MARK: - Public Methods
    
    func resetSemuaSkor(konfirmasi: @escaping (Bool) -> Void) {
        sedangMemproses = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.repositoriSkor.hapusSemuaSkor()
                
                DispatchQueue.main.async {
                    self.sedangMemproses = false
                    self.pesanKonfirmasi = "All scores have been reset successfully"
                    konfirmasi(true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.sedangMemproses = false
                    self.pesanKonfirmasi = "Failed to reset scores: \(error.localizedDescription)"
                    konfirmasi(false)
                }
            }
        }
    }
    
    func dapatkanTeksCaraBermain() -> String {
        return """
        🎮 GAME OBJECTIVE
        
        Mahjong Follow Rules is a puzzle game where you must identify and remove tiles according to the given rule for each level.
        
        📋 GAME MODES
        
        🎯 Challenge Mode
        Progress through increasingly difficult levels. Choose from:
        • Easy (3×3 grid)
        • Medium (4×4 grid)
        • Hard (5×5 grid)
        • Expert (6×6 grid)
        
        One wrong move ends the game!
        
        ⏱ Time Mode
        You have 2 minutes to complete as many levels as possible. Each correct level gives you 10 points.
        
        🎴 MAHJONG TILES
        
        • Circle tiles (1-9)
        • Character tiles (1-9)
        • Bamboo tiles (1-9)
        • Wind tiles (East, South, West, North)
        • Dragon tiles (Green, Red, White)
        
        📜 RULES EXAMPLES
        
        • Remove all Circle tiles
        • Remove all 5 tiles
        • Keep only Wind tiles
        • Remove odd numbered tiles
        
        💡 TIPS
        
        • Read the rule carefully
        • Take your time in Challenge Mode
        • Speed matters in Time Mode
        • Think strategically!
        
        Good luck! 🀄
        """
    }
    
    func bukaEmailUmpanBalik() -> String {
        return "support@mahjongfollowrules.com"
    }
    
    func bukaURLPenilaian() -> String? {
        return "itms-apps://itunes.apple.com/app/idXXXXXXXXXX?action=write-review"
    }
    
    // MARK: - Private Methods
    
    private func muatInformasiAplikasi() {
        if let versi = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versiAplikasi = versi
        }
    }
}

