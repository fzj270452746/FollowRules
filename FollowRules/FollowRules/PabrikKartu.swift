//
//  PabrikKartu.swift
//  FollowRules
//
//  Card Factory with Strategy Pattern
//

import Foundation

// MARK: - Pabrik Kartu (Card Factory)
class PabrikKartu: ProtocolPembuatKartu {
    
    private let generatorAcak: GeneratorBilanganAcak
    
    init(generatorAcak: GeneratorBilanganAcak = GeneratorAcakSistem()) {
        self.generatorAcak = generatorAcak
    }
    
    func buatKumpulanKartu(jumlah: Int, strategiPemilihan: StrategiPemilihanKartu) -> [EntitasKartu] {
        switch strategiPemilihan {
        case .acak:
            return buatKartuAcak(jumlah: jumlah)
        case .berbobot(let bobot):
            return buatKartuBerbobot(jumlah: jumlah, bobot: bobot)
        case .diatur(let kartuDiatur):
            return Array(kartuDiatur.prefix(jumlah))
        }
    }
    
    func dapatkanSemuaKartuTersedia() -> [EntitasKartu] {
        var semuaKartu: [EntitasKartu] = []
        
        // Kartu bernomor (1-9)
        for jenis in [JenisKartu.vague, .mayry, .diayu] {
            for nilai in 1...9 {
                semuaKartu.append(EntitasKartu(jenis: jenis, nilai: nilai))
            }
        }
        
        // Kartu angin
        for jenis in [JenisKartu.east, .south, .west, .north] {
            semuaKartu.append(EntitasKartu(jenis: jenis, nilai: nil))
        }
        
        // Kartu khusus
        for jenis in [JenisKartu.facu, .redzhong, .whiteblank] {
            semuaKartu.append(EntitasKartu(jenis: jenis, nilai: nil))
        }
        
        return semuaKartu
    }
    
    // MARK: - Private Methods
    
    private func buatKartuAcak(jumlah: Int) -> [EntitasKartu] {
        let semuaKartu = dapatkanSemuaKartuTersedia()
        var hasilKartu: [EntitasKartu] = []
        
        for _ in 0..<jumlah {
            let indeksAcak = generatorAcak.angkaAcak(dalam: 0..<semuaKartu.count)
            let kartuDipilih = semuaKartu[indeksAcak]
            hasilKartu.append(EntitasKartu(jenis: kartuDipilih.jenis, nilai: kartuDipilih.nilai))
        }
        
        return hasilKartu
    }
    
    private func buatKartuBerbobot(jumlah: Int, bobot: [JenisKartu: Double]) -> [EntitasKartu] {
        var hasilKartu: [EntitasKartu] = []
        let semuaKartu = dapatkanSemuaKartuTersedia()
        
        // Buat pool berbobot
        var poolBerbobot: [(kartu: EntitasKartu, bobot: Double)] = []
        for kartu in semuaKartu {
            let bobotKartu = bobot[kartu.jenis] ?? 1.0
            poolBerbobot.append((kartu, bobotKartu))
        }
        
        let totalBobot = poolBerbobot.reduce(0) { $0 + $1.bobot }
        
        for _ in 0..<jumlah {
            let nilaiAcak = generatorAcak.angkaAcakDouble() * totalBobot
            var akumulasi: Double = 0
            
            for (kartu, bobotKartu) in poolBerbobot {
                akumulasi += bobotKartu
                if nilaiAcak <= akumulasi {
                    hasilKartu.append(EntitasKartu(jenis: kartu.jenis, nilai: kartu.nilai))
                    break
                }
            }
        }
        
        return hasilKartu
    }
}

// MARK: - Generator Bilangan Acak (Random Number Generator)
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

// MARK: - Strategi Pemilihan Kartu
extension StrategiPemilihanKartu {
    static func strategiDinamis(tingkatKesulitan: TingkatKesulitan) -> StrategiPemilihanKartu {
        switch tingkatKesulitan {
        case .mudah:
            // Lebih banyak kartu bernomor
            return .berbobot([
                .vague: 3.0, .mayry: 3.0, .diayu: 3.0,
                .east: 0.5, .south: 0.5, .west: 0.5, .north: 0.5,
                .facu: 0.3, .redzhong: 0.3, .whiteblank: 0.3
            ])
        case .sedang:
            // Campuran seimbang
            return .berbobot([
                .vague: 2.0, .mayry: 2.0, .diayu: 2.0,
                .east: 1.0, .south: 1.0, .west: 1.0, .north: 1.0,
                .facu: 0.8, .redzhong: 0.8, .whiteblank: 0.8
            ])
        case .sulit, .pakar:
            // Lebih banyak variasi
            return .acak
        }
    }
}

