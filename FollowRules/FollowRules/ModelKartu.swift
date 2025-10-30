//
//  ModelKartu.swift
//  FollowRules
//
//  Mahjong Tile Model
//

import UIKit

// MARK: - Jenis Kartu (Tile Type)
enum JenisKartu: String, CaseIterable, Codable {
    case vague = "vague"      // 筒
    case mayry = "mayry"      // 万
    case diayu = "diayu"      // 条
    case east = "east"        // 东
    case south = "south"      // 南
    case west = "west"        // 北
    case north = "north"      // 西
    case facu = "facu"        // 發
    case redzhong = "redzhong" // 中
    case whiteblank = "whiteblank" // 白板
    
    var adalahKartuAngka: Bool {
        return self == .vague || self == .mayry || self == .diayu
    }
    
    var adalahKartuAngin: Bool {
        return self == .east || self == .south || self == .west || self == .north
    }
    
    var adalahKartuKhusus: Bool {
        return self == .facu || self == .redzhong || self == .whiteblank
    }
    
    var namaTampilan: String {
        switch self {
        case .vague: return "Circle"
        case .mayry: return "Character"
        case .diayu: return "Bamboo"
        case .east: return "East"
        case .south: return "South"
        case .west: return "West"
        case .north: return "North"
        case .facu: return "Green Dragon"
        case .redzhong: return "Red Dragon"
        case .whiteblank: return "White Dragon"
        }
    }
}

// MARK: - Model Kartu (Tile Model)
struct ModelKartu: Equatable, Hashable {
    let jenis: JenisKartu
    let nilai: Int? // 1-9 for numbered tiles, nil for wind/special tiles
    let id: UUID
    
    init(jenis: JenisKartu, nilai: Int? = nil) {
        self.jenis = jenis
        self.nilai = nilai
        self.id = UUID()
    }
    
    var namaGambar: String {
        if let nilai = nilai {
            return "\(jenis.rawValue)-\(nilai)"
        } else {
            return jenis.rawValue
        }
    }
    
    var deskripsiLengkap: String {
        if let nilai = nilai {
            return "\(jenis.namaTampilan) \(nilai)"
        } else {
            return jenis.namaTampilan
        }
    }
    
    static func == (lhs: ModelKartu, rhs: ModelKartu) -> Bool {
        return lhs.jenis == rhs.jenis && lhs.nilai == rhs.nilai
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(jenis)
        hasher.combine(nilai)
    }
}

// MARK: - Generator Kartu (Tile Generator)
class GeneratorKartu {
    static let bersama = GeneratorKartu()
    
    private init() {}
    
    func buatSemuaKartu() -> [ModelKartu] {
        var kartuSemua: [ModelKartu] = []
        
        // Add numbered tiles (1-9 for each type)
        for jenis in [JenisKartu.vague, .mayry, .diayu] {
            for nilai in 1...9 {
                kartuSemua.append(ModelKartu(jenis: jenis, nilai: nilai))
            }
        }
        
        // Add wind tiles
        for jenis in [JenisKartu.east, .south, .west, .north] {
            kartuSemua.append(ModelKartu(jenis: jenis, nilai: nil))
        }
        
        // Add special tiles
        for jenis in [JenisKartu.facu, .redzhong, .whiteblank] {
            kartuSemua.append(ModelKartu(jenis: jenis, nilai: nil))
        }
        
        return kartuSemua
    }
    
    func buatKartuAcak(jumlah: Int) -> [ModelKartu] {
        let semuaKartu = buatSemuaKartu()
        var kartuDipilih: [ModelKartu] = []
        
        for _ in 0..<jumlah {
            if let kartuAcak = semuaKartu.randomElement() {
                kartuDipilih.append(kartuAcak)
            }
        }
        
        return kartuDipilih
    }
}

