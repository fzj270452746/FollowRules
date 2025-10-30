//
//  ViewModelBeranda.swift
//  FollowRules
//
//  Home Screen ViewModel
//

import Foundation
import Combine

// MARK: - ViewModel Beranda (Home ViewModel)
class ViewModelBeranda: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var skorTertinggiTantangan: Int = 0
    @Published private(set) var skorTertinggiWaktu: Int = 0
    @Published private(set) var sedangMemuat: Bool = false
    @Published private(set) var pesanKesalahan: String?
    
    // MARK: - Dependencies
    private let repositoriSkor: RepositoriSkor
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(repositoriSkor: RepositoriSkor) {
        self.repositoriSkor = repositoriSkor
        muatSkorTertinggi()
    }
    
    // MARK: - Public Methods
    
    func mulaiModeTantangan(kesulitan: TingkatKesulitan) -> KonfigurasiPermainan {
        return KonfigurasiPermainan(
            mode: .tantangan,
            tingkatKesulitan: kesulitan,
            durasiWaktu: nil
        )
    }
    
    func mulaiModeWaktu() -> KonfigurasiPermainan {
        return KonfigurasiPermainan(
            mode: .waktu,
            tingkatKesulitan: nil,
            durasiWaktu: 120
        )
    }
    
    func muatUlangSkor() {
        muatSkorTertinggi()
    }
    
    // MARK: - Private Methods
    
    private func muatSkorTertinggi() {
        sedangMemuat = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let skorTantangan = self.repositoriSkor.dapatkanSkorTertinggi(untukMode: .tantangan)
            let skorWaktu = self.repositoriSkor.dapatkanSkorTertinggi(untukMode: .waktu)
            
            DispatchQueue.main.async {
                self.skorTertinggiTantangan = skorTantangan.first?.tingkatDicapai ?? 0
                self.skorTertinggiWaktu = skorWaktu.first?.skor ?? 0
                self.sedangMemuat = false
            }
        }
    }
}

