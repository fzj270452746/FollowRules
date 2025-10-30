//
//  RepositoriPenyimpanan.swift
//  FollowRules
//
//  Storage Repository Implementation
//

import Foundation

// MARK: - Kesalahan Repositori (Repository Errors)
enum KesalahanRepositori: Error, LocalizedError {
    case gagalMenyimpan(alasan: String)
    case gagalMemuat(alasan: String)
    case gagalMenghapus(alasan: String)
    case dataKorup
    case tidakDitemukan
    
    var errorDescription: String? {
        switch self {
        case .gagalMenyimpan(let alasan): return "Failed to save: \(alasan)"
        case .gagalMemuat(let alasan): return "Failed to load: \(alasan)"
        case .gagalMenghapus(let alasan): return "Failed to delete: \(alasan)"
        case .dataKorup: return "Data is corrupted"
        case .tidakDitemukan: return "Data not found"
        }
    }
}

// MARK: - Implementasi Repositori UserDefaults
class RepositoriPenyimpananUserDefaults: ProtocolRepositoriPenyimpanan {
    
    private let userDefaults: UserDefaults
    private let enkoder: JSONEncoder
    private let dekoder: JSONDecoder
    private let awalanKunci: String
    
    init(userDefaults: UserDefaults = .standard, awalanKunci: String = "com.followrules.") {
        self.userDefaults = userDefaults
        self.awalanKunci = awalanKunci
        self.enkoder = JSONEncoder()
        self.dekoder = JSONDecoder()
        
        enkoder.dateEncodingStrategy = .iso8601
        dekoder.dateDecodingStrategy = .iso8601
    }
    
    func simpan<T: Codable>(_ nilai: T, untukKunci kunci: String) throws {
        let kunciFull = awalanKunci + kunci
        
        do {
            let data = try enkoder.encode(nilai)
            userDefaults.set(data, forKey: kunciFull)
            userDefaults.synchronize()
        } catch {
            throw KesalahanRepositori.gagalMenyimpan(alasan: error.localizedDescription)
        }
    }
    
    func muat<T: Codable>(untukKunci kunci: String) throws -> T? {
        let kunciFull = awalanKunci + kunci
        
        guard let data = userDefaults.data(forKey: kunciFull) else {
            return nil
        }
        
        do {
            let nilai = try dekoder.decode(T.self, from: data)
            return nilai
        } catch {
            throw KesalahanRepositori.gagalMemuat(alasan: error.localizedDescription)
        }
    }
    
    func hapus(untukKunci kunci: String) throws {
        let kunciFull = awalanKunci + kunci
        userDefaults.removeObject(forKey: kunciFull)
        userDefaults.synchronize()
    }
    
    func hapusSemuaData() throws {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { kunci in
            if kunci.hasPrefix(awalanKunci) {
                userDefaults.removeObject(forKey: kunci)
            }
        }
        userDefaults.synchronize()
    }
}

// MARK: - Repositori Skor
class RepositoriSkor {
    
    private let repositoriPenyimpanan: ProtocolRepositoriPenyimpanan
    private let kunciSkorTantangan = "high_scores_challenge"
    private let kunciSkorWaktu = "high_scores_time"
    private let batasEntri = 10
    
    init(repositoriPenyimpanan: ProtocolRepositoriPenyimpanan) {
        self.repositoriPenyimpanan = repositoriPenyimpanan
    }
    
    func simpanSkor(_ skor: EntriSkor) throws {
        var daftarSkor: [EntriSkor]
        
        switch skor.mode {
        case .tantangan:
            daftarSkor = (try? repositoriPenyimpanan.muat(untukKunci: kunciSkorTantangan)) ?? []
        case .waktu:
            daftarSkor = (try? repositoriPenyimpanan.muat(untukKunci: kunciSkorWaktu)) ?? []
        case .latihan:
            return // Tidak menyimpan skor untuk mode latihan
        }
        
        daftarSkor.append(skor)
        daftarSkor.sort { $0.skor > $1.skor }
        
        if daftarSkor.count > batasEntri {
            daftarSkor = Array(daftarSkor.prefix(batasEntri))
        }
        
        switch skor.mode {
        case .tantangan:
            try repositoriPenyimpanan.simpan(daftarSkor, untukKunci: kunciSkorTantangan)
        case .waktu:
            try repositoriPenyimpanan.simpan(daftarSkor, untukKunci: kunciSkorWaktu)
        case .latihan:
            break
        }
    }
    
    func dapatkanSkorTertinggi(untukMode mode: JenisMode) -> [EntriSkor] {
        let kunci = mode == .tantangan ? kunciSkorTantangan : kunciSkorWaktu
        return (try? repositoriPenyimpanan.muat(untukKunci: kunci)) ?? []
    }
    
    func hapusSemuaSkor() throws {
        try repositoriPenyimpanan.hapus(untukKunci: kunciSkorTantangan)
        try repositoriPenyimpanan.hapus(untukKunci: kunciSkorWaktu)
    }
}

