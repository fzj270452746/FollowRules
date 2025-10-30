//
//  KontainerDependensi.swift
//  FollowRules
//
//  Dependency Injection Container
//

import Foundation

// MARK: - Kontainer Dependensi (Dependency Container)
class KontainerDependensi {
    
    static let bersama = KontainerDependensi()
    
    // MARK: - Singleton Services
    private(set) lazy var repositoriPenyimpanan: ProtocolRepositoriPenyimpanan = {
        return RepositoriPenyimpananUserDefaults()
    }()
    
    private(set) lazy var repositoriSkor: RepositoriSkor = {
        return RepositoriSkor(repositoriPenyimpanan: repositoriPenyimpanan)
    }()
    
    private(set) lazy var generatorAcak: GeneratorBilanganAcak = {
        return GeneratorAcakSistem()
    }()
    
    private(set) lazy var pabrikKartu: ProtocolPembuatKartu = {
        return PabrikKartu(generatorAcak: generatorAcak)
    }()
    
    private(set) lazy var pabrikAturan: ProtocolPembuatAturan = {
        return PabrikAturan(generatorAcak: generatorAcak)
    }()
    
    private(set) lazy var koordinatorAnimasi: ProtocolKoordinatorAnimasi = {
        return KoordinatorAnimasi()
    }()
    
    // MARK: - Factory Methods
    
    func buatLayananPermainan() -> ProtocolLayananPermainan {
        return LayananPermainan(
            pabrikKartu: pabrikKartu,
            pabrikAturan: pabrikAturan,
            repositoriSkor: repositoriSkor
        )
    }
    
    func buatViewModelBeranda() -> ViewModelBeranda {
        return ViewModelBeranda(repositoriSkor: repositoriSkor)
    }
    
    func buatViewModelPermainan(konfigurasi: KonfigurasiPermainan) -> ViewModelPermainan {
        let layananPermainan = buatLayananPermainan()
        return ViewModelPermainan(
            layananPermainan: layananPermainan,
            koordinatorAnimasi: koordinatorAnimasi,
            konfigurasi: konfigurasi
        )
    }
    
    func buatViewModelPengaturan() -> ViewModelPengaturan {
        return ViewModelPengaturan(repositoriSkor: repositoriSkor)
    }
    
    private init() {}
}

