//
//  PabrikKartu.swift
//  FollowRules
//
//  Card Factory - Refactored with Generator Pattern & Adapter Pattern
//

import Foundation

// MARK: - Pabrik Kartu (Card Factory) - Refactored Implementation
class PabrikKartu: ProtocolPembuatKartu {
    
    private let generatorAcak: GeneratorBilanganAcak
    private let generatorKartu: GeneratorKartuUniversal
    private let adapterStrategi: AdapterStrategiPemilihan
    
    init(generatorAcak: GeneratorBilanganAcak = GeneratorAcakSistem()) {
        self.generatorAcak = generatorAcak
        self.generatorKartu = GeneratorKartuUniversal(generatorAcak: generatorAcak)
        self.adapterStrategi = AdapterStrategiPemilihan(generatorAcak: generatorAcak)
    }
    
    func buatKumpulanKartu(jumlah: Int, strategiPemilihan: StrategiPemilihanKartu) -> [EntitasKartu] {
        let konverterStrategi = adapterStrategi.konversi(strategiPemilihan)
        return generatorKartu.hasilkan(kategori: konverterStrategi, jumlah: jumlah)
    }
    
    func dapatkanSemuaKartuTersedia() -> [EntitasKartu] {
        return generatorKartu.dapatkanSemuaKartu()
    }
}

// MARK: - Generator Kartu Universal
class GeneratorKartuUniversal {
    private let generatorAcak: GeneratorBilanganAcak
    private let koleksiKartu: KoleksiKartuDasar
    
    init(generatorAcak: GeneratorBilanganAcak) {
        self.generatorAcak = generatorAcak
        self.koleksiKartu = KoleksiKartuDasar()
    }
    
    func hasilkan(kategori: KategoriPemilihanKartu, jumlah: Int) -> [EntitasKartu] {
        let poolKartu = koleksiKartu.dapatkanPool(kategori: kategori)
        return seleksiKartu(dariPool: poolKartu, jumlah: jumlah)
    }
    
    func dapatkanSemuaKartu() -> [EntitasKartu] {
        return koleksiKartu.dapatkanSemuaKartu()
    }
    
    private func seleksiKartu(dariPool pool: [EntitasKartu], jumlah: Int) -> [EntitasKartu] {
        var hasil: [EntitasKartu] = []
        for _ in 0..<jumlah {
            if let kartuAcak = pool.randomElement() {
                hasil.append(EntitasKartu(jenis: kartuAcak.jenis, nilai: kartuAcak.nilai))
            }
        }
        return hasil
    }
}

// MARK: - Koleksi Kartu Dasar
class KoleksiKartuDasar {
    private var cacheSemuaKartu: [EntitasKartu]?
    private var cacheBerbobot: [KategoriPemilihanKartu: [EntitasKartu]] = [:]
    
    func dapatkanPool(kategori: KategoriPemilihanKartu) -> [EntitasKartu] {
        switch kategori {
        case .acak:
            return dapatkanSemuaKartu()
        case .berbobot(let bobot):
            return dapatkanPoolBerbobot(bobot: bobot)
        case .diatur(let kartuDiatur):
            return kartuDiatur
        }
    }
    
    func dapatkanSemuaKartu() -> [EntitasKartu] {
        if let cache = cacheSemuaKartu {
            return cache
        }
        
        var semuaKartu: [EntitasKartu] = []
        
        for jenis in [JenisKartu.vague, .mayry, .diayu] {
            for nilai in 1...9 {
                semuaKartu.append(EntitasKartu(jenis: jenis, nilai: nilai))
            }
        }
        
        for jenis in [JenisKartu.east, .south, .west, .north] {
            semuaKartu.append(EntitasKartu(jenis: jenis, nilai: nil))
        }
        
        for jenis in [JenisKartu.facu, .redzhong, .whiteblank] {
            semuaKartu.append(EntitasKartu(jenis: jenis, nilai: nil))
        }
        
        cacheSemuaKartu = semuaKartu
        return semuaKartu
    }
    
    private func dapatkanPoolBerbobot(bobot: [JenisKartu: Double]) -> [EntitasKartu] {
        if let cache = cacheBerbobot[.berbobot(bobot)] {
            return cache
        }
        
        var poolBerbobot: [EntitasKartu] = []
        let semuaKartu = dapatkanSemuaKartu()
        
        for kartu in semuaKartu {
            let bobotKartu = bobot[kartu.jenis] ?? 1.0
            let jumlahDuplikat = Int(bobotKartu * 10)
            for _ in 0..<jumlahDuplikat {
                poolBerbobot.append(EntitasKartu(jenis: kartu.jenis, nilai: kartu.nilai))
            }
        }
        
        cacheBerbobot[.berbobot(bobot)] = poolBerbobot
        return poolBerbobot
    }
}

// MARK: - Adapter Strategi Pemilihan
class AdapterStrategiPemilihan {
    private let generatorAcak: GeneratorBilanganAcak
    
    init(generatorAcak: GeneratorBilanganAcak) {
        self.generatorAcak = generatorAcak
    }
    
    func konversi(_ strategi: StrategiPemilihanKartu) -> KategoriPemilihanKartu {
        switch strategi {
        case .acak:
            return .acak
        case .berbobot(let bobot):
            return .berbobot(bobot)
        case .diatur(let kartuDiatur):
            return .diatur(kartuDiatur)
        }
    }
}

// MARK: - Kategori Pemilihan Kartu
enum KategoriPemilihanKartu: Hashable {
    case acak
    case berbobot([JenisKartu: Double])
    case diatur([EntitasKartu])
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .acak:
            hasher.combine(0)
        case .berbobot(let bobot):
            hasher.combine(1)
            hasher.combine(bobot.keys.sorted { $0.rawValue < $1.rawValue })
            hasher.combine(bobot.values.sorted())
        case .diatur(let kartu):
            hasher.combine(2)
            hasher.combine(kartu.count)
        }
    }
    
    static func == (lhs: KategoriPemilihanKartu, rhs: KategoriPemilihanKartu) -> Bool {
        switch (lhs, rhs) {
        case (.acak, .acak):
            return true
        case (.berbobot(let lhsBobot), .berbobot(let rhsBobot)):
            return lhsBobot == rhsBobot
        case (.diatur(let lhsKartu), .diatur(let rhsKartu)):
            return lhsKartu.count == rhsKartu.count && lhsKartu.elementsEqual(rhsKartu) { $0.jenis == $1.jenis && $0.nilai == $1.nilai }
        default:
            return false
        }
    }
}

// MARK: - Generator Bilangan Acak (保持原有接口)
protocol GeneratorBilanganAcak {
    func angkaAcak(dalam rentang: Range<Int>) -> Int
    func angkaAcakDouble() -> Double
    func acakBoolean() -> Bool
}

class GeneratorAcakSistem: GeneratorBilanganAcak {
    func angkaAcak(dalam rentang: Range<Int>) -> Int {
        return Int.random(in: rentang)
    }
    
    func angkaAcakDouble() -> Double {
        return Double.random(in: 0..<1)
    }
    
    func acakBoolean() -> Bool {
        return Bool.random()
    }
}

// MARK: - Strategi Pemilihan Kartu Extension (保持原有接口)
extension StrategiPemilihanKartu {
    static func strategiDinamis(tingkatKesulitan: TingkatKesulitan) -> StrategiPemilihanKartu {
        switch tingkatKesulitan {
        case .mudah:
            return .berbobot([
                .vague: 3.0, .mayry: 3.0, .diayu: 3.0,
                .east: 0.5, .south: 0.5, .west: 0.5, .north: 0.5,
                .facu: 0.3, .redzhong: 0.3, .whiteblank: 0.3
            ])
        case .sedang:
            return .berbobot([
                .vague: 2.0, .mayry: 2.0, .diayu: 2.0,
                .east: 1.0, .south: 1.0, .west: 1.0, .north: 1.0,
                .facu: 0.8, .redzhong: 0.8, .whiteblank: 0.8
            ])
        case .sulit, .pakar:
            return .acak
        }
    }
}
